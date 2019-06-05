# Use offical Ubuntu 18.04 Release as parent image
FROM ubuntu:18.04

# Set the directory for building the product
WORKDIR /linux

# Copy in the scripts and content needed to build uBoot and the kernel
COPY scripts /linux/scripts

# Copy the Makefile into the docker filesystem
COPY Makefile /linux/Makefile

# Copy the patches directory into the docker filesystem
COPY patches /linux/patches

# Install additional packages that allow us to run the 32-bit linux add-in on a 64-bit host
RUN  /linux/scripts/setup-64bit-ubuntu-host.sh

# Note: We don't install the Linux add-in and CCES in the docker image as that would really bloat the image size

# Open up the TFTP ports
EXPOSE 69
EXPOSE 8099

