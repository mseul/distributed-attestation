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

RUN git clone -b kirkstone git://git.yoctoproject.org/poky
RUN cd poky
RUN git clone git://git.yoctoproject.org/meta-raspberrypi
#RUN source oe-init-build-env
#RUN bitbake-layers add-layer ../meta-raspberrypi #need to re-init layers?
#RUN bitbake core-image-minimal #need to build specific raspi image instead?

