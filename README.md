# Distributed Attestation Project for DFSC6347

## Housekeeping

Author: Matthias Seul (mxs231@shsu.edu)

Licensed under: MIT License (see LICENSE file)

## Executive Summary of Project

The Distributed Attestation project aims to create a Poky-Linux-based IoT-specific image that runs an optimized version of openSCAP and communicates via DTN7.

Apart from detailed manuals, Dockerfiles and tooling, the project also contains a set of testing results of performed test cycles.

## Step-by-Step Guides

1. [Running openSCAP standalone](./docs/OpenSCAP-Standalone.md)
2. [Creating a Yocto Build Environment and Building Poky](./docs/Creating-Yocto-Build-Enviromnent.md)
3. [Creating and customizing a Poky Container](./docs/Creating-Poky-Container.md)
4. [Installing CORE](./docs/Installing-CORE.md)
5. [Running Scenarios and gathering results](./docs/Running-Scenarios.md)

## Overview of Directories and Files

- /*.sh /*.sh - Tooling for scenario building, running, orchestration
- /CORE-Network - Reference network configs and patch for Podman use
- /Docker-dtn7-poky - Customized Container image, derived from imported Poky base image
- /Docker-scenario-tooling - Customized image with additional testing tooling, derviced from DTN7-poky image
- /Docker-Yocto-build-env - Container image to set up and build Yocto environment
- /docs - Step-by-Step Manuals
- /Yocto-build-configs - Reference Bitbake configs with components added


## Hosted Third-Party Code

The repository does not contain any third-party code, except for the CORE patch for podman (CORE-Network/coreemu-patch-podman), which is taken from the CORE project owned by the Boeing Corporation and licensed under the Apache 2.0 license.

For all other third-party components, links and instructions are provided to acquire the necessary components.

None of the components have restrictive or commerical licenses, though validating the individual licenses work with a given environment is strongly recommended.


## References and Attribution

[openSCAP by Red Hat, Inc.](https://github.com/OpenSCAP/openscap)

[Yocto / Poky, Yocto Project and The Linux Foundation](https://www.yoctoproject.org/software-overview/)

[CORE, The Boeing Corporation](https://coreemu.github.io/core/)

[DTN7, L. Baumgärtner,  J. Höchst,  T. {Meuser](https://github.com/dtn7/dtn7-rs/tree/v0.18.1/core/dtn7)

