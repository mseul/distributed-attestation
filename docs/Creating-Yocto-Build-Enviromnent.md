# Creating a Yocto Build Enviromnent and Poki Image

## Creating a Yocto Build Server with Ubuntu Server 20.04 LTS

### Prepping the System

Use Ubuntu Server 20.04 LTS or next-newest LTS image.

Deploy with AT LEAST 100 GB of storage space, 4-8 GB of RAM and two CPUs/Cores.

Force Ubuntu Storage manager to use all available space, server will otherwise only use about 50% of availalbe space.

```
lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv
```

### Add Podman repo

```
. /etc/os-release
sudo sh -c "echo 'deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list"
wget -nv https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_${VERSION_ID}/Release.key -O- | sudo apt-key add -
sudo apt update
sudo apt -y install podman
```


### Setting up the Yocto Environment

#### Yocto Dockerfile

```
FROM ubuntu:20.04
SHELL ["/bin/bash", "-c"] ##Requires docker-specific format (--format docker), not part of OCI specification
RUN export DEBIAN_FRONTEND=noninteractive
RUN ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

#Baseline libraries
RUN apt-get update && apt-get install --autoremove --no-install-recommends --show-progress -y locales \
	gawk wget git diffstat unzip texinfo \ 
	gcc build-essential chrpath socat cpio python3 python3-pip python3-pexpect \
	xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa \
	libsdl1.2-dev pylint3 xterm python3-subunit mesa-common-dev zstd liblz4-tool libncurses5-dev

#additional libraries
RUN apt-get update && apt-get install --autoremove --no-install-recommends --show-progress -y file

RUN pip3 install gnureadline

RUN dpkg-reconfigure --frontend noninteractive tzdata

RUN groupadd -g 1000 dev \
            && useradd -u 1000 -g dev -d /home/dev dev \
            && mkdir /home/dev \
            && chown -R dev:dev /home/dev

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
USER dev
WORKDIR /home/dev
```

#### Building Yocto Image

```
podman build -t "pokibuild:latest" .
podman volume create poki
```

IMPORTANT: Volume must be created and used to ensure persistence between builds and caching. Builds will otherwise take HOURS.


Increase pids_limit in container.conf (your system's), for example 1000000
Too low PID limit may cause Yocto build to fail, https://man.archlinux.org/man/containers.conf.5.en


#### Running Yocto Image

podman run --rm --tmpfs /tmp -v poki:/home/pokybuild/poky -i -t "pokibuild:latest" /bin/bash

#### Prepping the Build environment (inside Yocto Container)

```
git clone -b kirkstone git://git.yoctoproject.org/poky
cd poky
git clone -b kirkstone git://git.yoctoproject.org/meta-raspberrypi
git clone -b kirkstone git://git.openembedded.org/meta-openembedded
git clone -b kirkstone git://git.openembedded.org/openembedded-core
git clone -b kirkstone git://git.yoctoproject.org/meta-security

source oe-init-build-env rpi-build
```


#### Update conf/local.conf

##### to use caching

```
BB_SIGNATURE_HANDLER = "OEEquivHash"
BB_HASHSERVE = "auto"
BB_HASHSERVE_UPSTREAM = "hashserv.yocto.io:8687"#
SSTATE_MIRRORS ?= "file://.* https://sstate.yoctoproject.org/all/PATH;downloadfilename=PATH"
```

##### to activate RaspberryPi Support

```
MACHINE ??= "raspberrypi4-64"
set LICENSE_FLAGS_ACCEPTED="synaptics-killswitch"
```

MACHINE can be any of

- raspberrypi
- raspberrypi0
- raspberrypi0-wifi
- raspberrypi0-2w-64
- raspberrypi2
- raspberrypi3
- raspberrypi3-64 (64 bit kernel & userspace)
- raspberrypi4
- raspberrypi4-64 (64 bit kernel & userspace)
- raspberrypi-cm (dummy alias for raspberrypi)
- raspberrypi-cm3

see: https://meta-raspberrypi.readthedocs.io/en/latest/layer-contents.html


#### To enable openSCAP and additional features

```
IMAGE_INSTALL:append = " os-release openembedded-release oe-scap scap-security-guide "
IMAGE_INSTALL:append = " iproute2 iproute2-tc ethtool "
IMAGE_INSTALL:append = " python3-pip python3-wheel "
DISTRO_FEATURES:append = " security"
```
  

#### Update conf/bbLayers.conf

Should include the following layer dependencies

```
BBLAYERS ?= " \
  /home/pokybuild/poky/poky/meta \
  /home/pokybuild/poky/poky/meta-poky \
  /home/pokybuild/poky/poky/meta-yocto-bsp \
  /home/pokybuild/poky/poky/meta-raspberrypi \
  "

BBLAYERS += "${TOPDIR}/../meta-openembedded/meta-oe"
BBLAYERS += "${TOPDIR}/../meta-openembedded/meta-python"
BBLAYERS += "${TOPDIR}/../meta-security/meta-security-compliance"
BBLAYERS += "${TOPDIR}/../meta-openembedded/meta-perl"
```


#### Trigger Yocto Build of customized Poky

```
bitbake core-image-minimal
```

First build process can take several hours! 


Clean up with 
```
bitbake -c do_cleanall core-image-minimal
```

Bitbake Cheat Sheet (All commands)
https://www.openembedded.org/wiki/Bitbake_cheat_sheet


#### Acquiring Completed Builds

Images can be found under BUILDROOT/tmp/deploy/images/FORMFACTOR/

Images are provided in multiple compression formats and components.
These can be used to either flash an image, build an ISO or create a Container.


For example, the following contains a fully functional root file system that can be imported into a Container: 
```
core-image-minimal-raspberrypi4-64.rootfs.tar.bz2
```


	
## Links

### Yocto

[Building Yocto](https://www.yoctoproject.org/software-overview/)

[Customizing Yocto for Hardware](https://docs.yoctoproject.org/brief-yoctoprojectqs/index.html#customizing-your-build-for-specific-hardware)

[Yocto Build Overview](https://docs.yoctoproject.org/overview-manual/concepts.html#images)

[Yocto Tasks Cheatsheet](https://docs.yoctoproject.org/dev-manual/common-tasks.html)

### RaspberryPi @ Yocto

[RaspberryPi Layer Documentation](https://meta-raspberrypi.readthedocs.io/en/latest/readme.html)

[RaspberryPi Layer Repo for Kirkstone](https://git.yoctoproject.org/meta-raspberrypi/log/?h=kirkstone)

### OpenSCAP & Yocto

[Security/Compliance Layer](https://git.yoctoproject.org/meta-security/tree/meta-security-compliance/README)

[WRLinux OpenSCAP Layer Archive](https://web.archive.org/web/20210923140708/https://static.open-scap.org/ssg-guides/ssg-wrlinux8-guide-basic-embedded.html)

