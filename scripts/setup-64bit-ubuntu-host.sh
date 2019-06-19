#!/bin/bash
# Copyright (C) 2019 Analog Devices Inc. All Rights Reserved.
# Script to install all the required packages needed to install the 32-bit CCES and Linux add-in packages on a 64-bit host,
# and to install all relevant packages required to build and install Linux on the EZ-KIT

export DEBIAN_FRONTEND=noninteractive

#Determine if we are running within docker
IS_DOCKER="n"
if [ `cat /proc/1/cgroup | grep docker | wc -l` -gt 0 ]
then
    IS_DOCKER="y"
    echo "Ah, I'm running in a docker image!"
else
    echo "Ah, this is a native Ubuntu machine!"
fi

SCMD=""
if [ "${IS_DOCKER}" == "n" ]
then
    # We need to elevate to su to install packages when not in a docker container
    SCMD="sudo"
fi

# Configure the host to support the 32-bit subsystem
${SCMD} dpkg --add-architecture i386
${SCMD} apt-get update
# Install packages required to run the 32-bit binaries on our 64-bit host
${SCMD} apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 libz1:i386 wget
# Install the packages required to build and install Linux, as documented in the Linux Add-In User Guide
${SCMD} apt-get install -y \
    automake \
    dh-autoreconf \
    minicom \
    tftpd-hpa \
    git-all \
    subversion \
    openssh-server \
    ncurses-dev \
    libtool \
    texinfo \
    intltool \
    debconf-utils \
    bc \
    rsync \
    cpio \
    python \
    unzip