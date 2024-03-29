# Build Tools For Analog Devices Linux Add-In: Github repository and Docker image
This repository contains build scripts provided by Analog Devices to assist customers in building the Linux add-in.
The scripts simplify the process of installing the Linux Add-In and building the uBoot bootloader and kernel from the provided sources.
The scripts can be run on a native PC running 64-bit Ubuntu 18.04, or within the ADI provided docker image.
The docker image will contain all the scripts required to download and build the Linux add-in from source, using a 64-bit variant of Ubuntu

## Quick Start
To build uBoot and the kernel/filesystem under the ADI provided docker image on Docker Hub:
```bash
make all USE_DOCKER=yes
```
This will pull down the **analogdevices/dte-linux-addin** docker image which will build the components, leaving the source and build components available on the host once completed.

To build uBoot and the kernel/filesystem on the native host Linux machine:
```bash
make all
```
This will also leave the build products in the build directory on the local host.

## Support and Advice
Any questions regarding this repository or the ADI Linux add-in Docker image should be post on the [Analog Devices Linux Add-in Engineer Zone Forum](https://ez.analog.com/dsp/software-and-development-tools/linux-for-adsp-sc5xx-processors/f/q-a)

For users wanting a helpful guide to install the latest docker on Ubuntu see [Here](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04)

## Licensing
The contents of this repository are provided under the Free BSD license, please see LICENSE.md for more details.

## Obtaining the latest version of this repository
The latest version of these scripts can be obtained from [Github](https://github.com/analogdevicesinc/linux-addin-scripts)

### Checking out the correct version of this repository
The repository will use branches to maintain different versions of the scripts.
The following branch naming strategy will be used:
Branch | Description
-------|------------
master | Scripts for 64-bit Ubuntu 18.04 LTS building the latest release of the Linux add-in
\<OS>-\<OSVER>-linux-addin-\<LINUXVER> | Support for version LINUXVER of the add-in building on OS version OSVER

For example the ubuntu-18.04-linux-addin-1.3.0 branch will support building the 1.3.0 release of the Linux add-in under Ubuntu 18.04.

## Running under Docker

### Pulling the official ADI docker image from docker.com

### Building a local copy of the docker image
By default the Makefile will build using the docker repository provided by Analog Devices via the Docker Hub.
If you wish to build a local copy of the docker repository, the Dockerfile and associated scripts in this repository will allow you to create your own version of the docker repository.
To build a local copy of the docker image:
1. Edit the Makefile to update the **DOCKER_IMAGE_NAME** and **DOCKER_IMAGE_VERSION** variables
2. Invoke the following command:
```bash
make docker-image
```
Invoking the build will now use your locally built docker repository.
The docker build creates a sub-directory on the local host named **build** which will contain all sources and artifacts from the build.
**Note** that the Linux sources contain files that have the same name but differ in case. This means that you cannot invoke this build from a Windows host unless it is running with a case-sensitive file system. 

## Running on a native Linux host
By default the Makefile is configured to build on a native Linux host rather than inside a docker repository.
Before invoking make you must ensure that you have installed all the relevant packages. This can be performed by running the provided **scripts/setup-64bit-ubuntu-host.sh** script:
```bash
sudo ./scripts/setup-64bit-ubuntu-host.sh
```