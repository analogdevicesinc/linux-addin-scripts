# Makefile to manage the installation and building of the ADI Linux Add-In components
# This Makefile can be run on a native Linux host or in a docker image
# For more information see the accompanying README.md
# Copyright Analog Devices Inc. 2019, All Rights Reserved

# To build components on the local host simply run 'make all'
# To build a docker image and run the build on a docker image run 'make all USE_DOCKER=yes'
# Note: DO NOT add USE_DOCKER=yes to this makefile or you will recursively build a docker 
# image inside a docker image inside a docker image etc, time will slow down, Michael Caine will
# become your father-in-law and you will lose all sense of reality.

# Options to configure
DOCKER_IMAGE_NAME=analogdevices/dte-linux-addin
DOCKER_IMAGE_VERSION=1.3.0
# Version of the Linux add-in to install
LINUXADDIN_VERSION=1.3.0
# Version of CrossCore Embedded Studio to install
CCES_VERSION=2.8.3
# Processor to target when building from source
BUILD_TARGET=sc589
# Hardware variant to target when building from source
BUILD_BOARD=ezkit
# Directory to place files when uploading via TFTP
TFTP_DIR=/tftpboot
# Directory where the CrossCore and Linux add-in kits are downloaded to.
# This directory on the host is also shared with the docker image, if using one
PACKAGE_DIR=`pwd`/kits
# Directory where patches not provided in the Linux add-in are stored
PATCH_DIR=`pwd`/patches

# Makefile variables, not typically changed
LINUXADDIN_KIT=adi-LinuxAddinForCCES-linux-x86-$(LINUXADDIN_VERSION).deb
CCES_KIT=adi-CrossCoreEmbeddedStudio-linux-x86-$(CCES_VERSION).deb
LINUXADDIN_URL=https://download.analog.com/tools/LinuxAddInForCCES/Releases/Release_$(LINUXADDIN_VERSION)
CCES_URL=http://download.analog.com/tools/CrossCoreEmbeddedStudio/Releases/Release_$(CCES_VERSION)

# Installation directories
LINUXADDIN_KIT_DIR=/opt/analog/cces-linux-add-in/$(LINUXADDIN_VERSION)
CCES_KIT_DIR=/opt/analog/cces/$(CCES_VERSION)

# Source/build directories
BUILD_DIR=`pwd`/build
UBOOT_SOURCE_DIR=$(BUILD_DIR)/u-boot
LINUX_SOURCE_DIR=$(BUILD_DIR)/linux

# Ensure that package installation is not interactive
DEBIAN_FRONTEND=noninteractive

ifeq ($(USE_DOCKER),yes)
  LOCAL_BUILD_COMPONENTS=docker-image invoke-docker-build
else
  LOCAL_BUILD_COMPONENTS=download-packages install-packages install-sources build-uboot build-linux
endif

# ##############################
# Makefile rules

# All rule can behave different depending on whether you are invoking a local build or docker
# related build. If you 'make all' and DOCKER_BUILD=yes, build will create the docker image
# then invoke a build on that image.
# NOTE: Creation of the docker image is slow. Once built you want to avoid rebuilding it
#       and simply 'make invoke-docker-build'
.PHONY: all
all:$(LOCAL_BUILD_COMPONENTS)

# The docker build assumes that the docker image already exists and will invoke an installation,
# unpack and build of all the components.
.PHONY: invoke-docker-build
invoke-docker-build:
	docker run -it -v `pwd`:/linux/mount $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION) cd /linux/mount &&  make all

# Docker rule is only used if you are building a docker image to perform all the tasks on
docker-image:
	docker build --tag=$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION) .

.PHONY: download-packages
download-packages: $(PACKAGE_DIR)/$(LINUXADDIN_KIT) $(PACKAGE_DIR)/$(CCES_KIT)

# Package rules
.PHONY: install-packages
install-packages:
	CCES_VERSION=$(CCES_VERSION) \
	LINUXADDIN_VERSION=$(LINUXADDIN_VERSION) \
	PACKAGE_DIR=$(PACKAGE_DIR) \
	./scripts/install-packages.sh

$(PACKAGE_DIR)/$(LINUXADDIN_KIT): $(PACKAGE_DIR)
	cd $(PACKAGE_DIR) && wget -q $(LINUXADDIN_URL)/$(LINUXADDIN_KIT)

$(PACKAGE_DIR)/$(CCES_KIT):
	cd $(PACKAGE_DIR) && wget -q $(CCES_URL)/$(CCES_KIT)

$(PACKAGE_DIR):
	mkdir -p $(PACKAGE_DIR)

.PHONY: clean
clean: clean-packages

.PHONY: clean-packages
clean-packages: clean-cces-kit clean-linuxaddin-kit

.PHONY: clean-cces-kit
clean-cces-kit:
	rm -f $(PACKAGE_DIR)/$(CCES_KIT)

.PHONY: clean-linuxaddin-kit
clean-linuxaddin-kit:
	rm -f $(PACKAGE_DIR)/$(LINUXADDIN_KIT)

# Source rules
.PHONY: install-sources
install-sources: install-uboot-sources install-linux-sources

# The 1.3.0 release of the Linux add-in requires a patch to the uboot sources
# If the patching fails, it means you are probably using a newer version of the kernel
# that doesn't need patching.
.PHONY: install-uboot-sources
install-uboot-sources: $(UBOOT_SOURCE_DIR)
	cd $(UBOOT_SOURCE_DIR) && \
	  tar -xf $(LINUXADDIN_KIT_DIR)/uboot-sc5xx-$(LINUXADDIN_VERSION)/src/uboot-sc5xx-$(LINUXADDIN_VERSION).tar.gz
	cd $(UBOOT_SOURCE_DIR)/uboot && \
	  cat $(LINUXADDIN_KIT_DIR)/patches/sc589-ezkit-2.0-eth-uboot.patch | patch -p 1

$(UBOOT_SOURCE_DIR):
	mkdir -p $(UBOOT_SOURCE_DIR)

.PHONY: clean-uboot-sources
clean-uboot-sources:
	rm -rf $(UBOOT_SOURCE_DIR)

# Building the 1.3.0 release of the Linux filesystem requires a couple of patches in
# order to build on new Ubuntu hosts.
.PHONY: install-linux-sources
install-linux-sources: $(LINUX_SOURCE_DIR)
	cd $(LINUX_SOURCE_DIR) && tar -xf $(LINUXADDIN_KIT_DIR)/buildroot-sc5xx-$(LINUXADDIN_VERSION)/src/buildroot-sc5xx-$(LINUXADDIN_VERSION).tar.gz
	cd $(LINUX_SOURCE_DIR)/buildroot/linux/linux-kernel && \
	  cat $(LINUXADDIN_KIT_DIR)/patches/sc589-ezkit-2.0-eth-kernel.patch | patch -p 1
	cp $(PATCH_DIR)/0002-port-to-perl-5.22-and-later.patch \
	  $(LINUX_SOURCE_DIR)/buildroot/package/automake
	cp $(PATCH_DIR)/0001-fix-openssl-1.0.2.patch \
	  $(LINUX_SOURCE_DIR)/buildroot/package/pound

$(LINUX_SOURCE_DIR):
	mkdir -p $(LINUX_SOURCE_DIR)

.PHONY: clean-linux-sources
clean-linux-sources: clean-uboot-sources clean-linux-sources

# build rules

.PHONY: build-uboot
build-uboot:
	cd $(UBOOT_SOURCE_DIR)/uboot && \
	PATH=$(PATH):$(CCES_KIT_DIR)/ARM/arm-none-eabi/bin \
	make clean && \
	PATH=$(PATH):$(CCES_KIT_DIR)/ARM/arm-none-eabi/bin \
	make $(BUILD_TARGET)-$(BUILD_BOARD)_defconfig && \
	PATH=$(PATH):$(CCES_KIT_DIR)/ARM/arm-none-eabi/bin \
	make

.PHONY: build-linux
build-linux:
	cd $(LINUX_SOURCE_DIR)/buildroot && \
	PATH=$(PATH):$(LINUXADDIN_KIT_DIR)/ARM/arm-linux-gnueabi/bin \
	make clean && \
	PATH=$(PATH):$(LINUXADDIN_KIT_DIR)/ARM/arm-linux-gnueabi/bin \
	make $(BUILD_TARGET)-$(BUILD_BOARD)_defconfig && \
	PATH=$(PATH):$(LINUXADDIN_KIT_DIR)/ARM/arm-linux-gnueabi/bin \
	make

