# Use offical Ubuntu 18.04 Release as parent image
FROM ubuntu:18.04

# Set the directory for building the product
WORKDIR /linux

# Copy useful information and licensing to the docker image
COPY README.md .
COPY LICENSE.md .

# Copy in the scripts and content needed to build uBoot and the kernel
COPY scripts /linux/scripts

# Copy the Makefile into the docker filesystem
COPY Makefile /linux/Makefile

# Copy the patches directory into the docker filesystem
COPY patches /linux/patches

# Install additional packages that allow us to run the 32-bit linux add-in on a 64-bit host
RUN DEBIAN_FRONTEND=noninteractive dpkg --add-architecture i386
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 libz1:i386 wget
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y automake dh-autoreconf minicom \
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

# Note: We don't install the Linux add-in and CCES in the docker image as that would really bloat the image size

# Open up the TFTP ports
EXPOSE 69
EXPOSE 8099

