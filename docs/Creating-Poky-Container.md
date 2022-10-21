# Creating a Poky Container

## Import Generated Image

```
podman import core-image-minimal-raspberrypi4-64.tar.bz2 pokirun:latest

```

Image should then becomer run-able with:

```
podman run --rm -ti "pokirun:latest" /bin/sh
```


## Minimizing the Container Size

Delete non-applicable guide XMLs from /usr/share/xml/scap/ssg/content/
(Essentially, anything not "ssg-openembedded-*")

Delete /usr/share/scap-security-guide
Delete all schemas from /usr/share/openscap/schemas/oval/ EXCEPT "5.11.1"


Reduces size to 95.6 MB image size, or 12.7% of original 765 MB chonk

This can be automated by including in a derived Container file with RUN commands


## Patching the OS Identification

Yocto Poky might not be properly detected as an OpenEmbedded-compatible OS.

Overwrite /etc/os-release contents with

```
ID=nodistro
NAME="OpenEmbedded"
VERSION="nodistro.0"
VERSION_ID=nodistro.0
PRETTY_NAME="OpenEmbedded nodistro.0"
```

Source: https://git.yoctoproject.org/meta-security/commit/meta-security-compliance/recipes-openscap/scap-security-guide?id=caec0c657de7d0e5f565bd63c501ba287db5dcd8

## Testing openSCAP in Created container

```
oscap xccdf eval --report basic-embedded.html --profile xccdf_org.ssgproject.content_profile_basic-embedded /usr/share/xml/scap/ssg/content/ssg-openembedded-ds.
```

Should now run and display passes. A few checks will always remain as "notchecked" as Poky does not have the aspect they are checking.


## Installing DTN7

Fetch newest release directly from website or build by hand

wget https://github.com/dtn7/dtn7-rs/releases/download/v0.18.1/dtn7-0.18.1-armv7-unknown-linux-musleabihf.tar.gz

Install by unpacking, binaries should be immediately functional.


## Creating a derived Container

The patches and adjustments can be rolled up into a separate container via the following Dockerfile:

```
FROM pokirun:latest
USER root
COPY ./dtn7-0.18.1-armv7-unknown-linux-musleabihf.tar.gz ./dtn7.tar.gz
RUN tar -xzf dtn7.tar.gz
RUN rm -f dtn7.tar.gz
RUN mv ./dtn7-0.18.1/ ./dtn7
#RUN pip3 install ecdsa
COPY ./os-release /etc/os-release
```

podman build -t "pokirun:dtn7" .

