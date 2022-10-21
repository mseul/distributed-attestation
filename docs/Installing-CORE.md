# Installing and Using CORE Networking

## Podman And Rootless

Some of the changes that CORE makes will require root-level access to properly set up the containers.
Running Podman (and the launching CORE process) as root may therefore be required.


## Installing CORE prerequistes from source
```
sudo apt-get install proj-bin
sudo apt-get install build-essential
```

### install sqlite for proj

Installing sqlite from repo may result in an incompatible/outdated version being installed. Installing fresh from source is preferred.
Also, libtiff and libcurl dev packages are required for subsequent build steps.

```
wget https://www.sqlite.org/2022/sqlite-autoconf-3390300.tar.gz
tar -xzvf sqlite-autoconf-3390300.tar.gz
sudo mv ./sqlite-autoconf-3390300 /opt/sqlite3
sudo apt-get install libtiff5-dev libcurlpp-dev -y
source ~/.bashrc
```

### install proj from source

PROJ is required as CORE uses pyproj to perform mapping and coordinate-based node location.


```
wget https://download.osgeo.org/proj/proj-9.1.0.tar.gz
cd proj-9.1.0
mkdir build
cd build
cmake ..
cmake --build .
cmake --build . --target install
#source ~/.bashrc
projsync --system-directory --all

export PROJ_VERSON=2.6.1
export PROJ_DIR=/usr/
export PROJ_WHEEL=true
export PROJ_INCDIR=YOUR_PROJ_BUILD_DIR_HERE/proj-9.1.0/src/
export PROJ_LIBDIR=YOUR_PROJ_BUILD_DIR_HERE/proj-9.1.0/build/lib/
sudo pip install cython
```


## Provide PROJ H/SO files for compilation

This is a critical step as the pyproj included with CORE will require an on-the-spot compilation.

```
sudo cp YOUR_PROJ_BUILD_DIR_HERE/proj-9.1.0/src/*.h /usr/include
sudo cp YOUR_PROJ_BUILD_DIR_HERE/proj-9.1.0/build/lib/*.so /usr/lib
```

## Installing CORE

### Preparation

```
git clone https://github.com/coreemu/core.git
cd core/
./setup.sh
source ~/.bashrc
pip install wheel && GRPC_BUILD_WITH_BORING_SSL_ASM="" GRPC_PYTHON_BUILD_SYSTEM_RE2=true GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=true GRPC_PYTHON_BUILD_SYSTEM_ZLIB=true pip install grpcio pyproj
```

### Automated install

Use "debian" to set the correct Linux OS flavor, change setting if different distribution used.

```
inv install -l -i debian -v
```

### Manual Install

```
sudo -v
sudo apt install -y automake pkg-config gcc libev-dev nftables iproute2 ethtool tk python3-tk bash
python3 -m pip install --user grpcio==1.27.2 grpcio-tools==1.27.2
./bootstrap.sh
./configure --prefix=/usr/local
make -j$(nproc)
sudo make install
cd daemon && poetry build -f wheel
cd daemon && sudo python3 -m pip install dist/*
cd daemon && poetry env info -p
sudo cp daemon/scripts/core-cli /usr/local/bin/core-cli
sudo cp daemon/scripts/core-manage /usr/local/bin/core-manage
sudo cp daemon/scripts/core-gui /usr/local/bin/core-gui
sudo cp daemon/scripts/core-imn-to-xml /usr/local/bin/core-imn-to-xml
sudo cp daemon/scripts/core-cleanup /usr/local/bin/core-cleanup
sudo cp daemon/scripts/core-service-update /usr/local/bin/core-service-update
sudo cp daemon/scripts/coresendmsg /usr/local/bin/coresendmsg
sudo cp daemon/scripts/core-daemon /usr/local/bin/core-daemon
sudo cp daemon/scripts/core-route-monitor /usr/local/bin/core-route-monitor
sudo mkdir -p /etc/core
sudo cp -n daemon/data/core.conf /etc/core
sudo cp -n daemon/data/logging.conf /etc/core
sudo mkdir -p /usr/local/share/core
sudo cp -r daemon/examples /usr/local/share/core
sudo cp /tmp/tmpyynqhyj2 /lib/systemd/system/core-daemon.service
```


### install "zebra" /  FRR

Necessary for some of the network setups.

```
sudo apt-get install frr:armhf frr -y
sudo systemctl enable core-daemon
sudo systemctl start core-daemon
```

### Install EMANE for simulated wifi networks.

Ensure proper versions of libpcap and protobuf are installed.

```
sudo apt-get purge libpcap0.8-dev libpcap0.8 libpcap-dev
sudo apt-get install libtool libxml2 libxml2-dev libprotobuf-dev libpcre3-dev uuid-dev libpcap0.8-dev -y
pip uninstall protobuf
pip install protobuf==3.19.0 #downgrade protobuf to supported version
```

Install EMANE

```
git clone https://github.com/adjacentlink/emane.git
cd emane
./autogen.sh
./configure --prefix=/usr 
sudo make install
```


### (Optional) Install PROJ database

If CORE fails to start, initialize a session or add nodes, the installed database might need to be reset with the one build from source.
 
sudo cp YOUR_PROJ_BUILD_DIR_HERE/proj-9.1.0/build/data/ /usr/share/proj/proj.db


### CORE-inside-Container Support

To work with Containers, CORE requires a few libraries to be installed. The instructions give ealier to create the container include these already.

Directly from repo, if available:
```
RUN apt-get install -y iproute2 ethtool
```

Via Yocto conf/local.conf
```
IMAGE_INSTALL:append = " iproute2 iproute2-tc ethtool "
```

### CORE and Podman

CORE unfortunately has hardcoded "docker" calls in the DockerNode code file.

These can be 1:1 replaced with "Podman" or an alias / shim shell file can be used.


## Links

[CORE Main Page](https://coreemu.github.io/core/)

[CORE Github Repo & Source](https://github.com/coreemu/core)

[CORE Install Steps](https://coreemu.github.io/core/install.html)

[CORE Docker Support](https://coreemu.github.io/core/docker.html)

[CORE Python API](https://coreemu.github.io/core/python.html)


