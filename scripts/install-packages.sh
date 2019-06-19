#!/bin/bash
# Copyright (C) 2019 Analog Devices Inc. All Rights Reserved.

# Script to automatically install CrossCore Embedded Studio and the 
# Linux add-in. Should be called from the top level Makefile

export DEBIAN_FRONTEND=noninteractive
echo "adi-cces-${CCES_VERSION} adi-cces-${CCES_VERSION}/run-ocd-config boolean true" | debconf-set-selections
echo "adi-cces-${CCES_VERSION} adi-cces-${CCES_VERSION}/accept-sla boolean true" | debconf-set-selections
echo "adi-cces-linux-add-in-${LINUXADDIN_VERSION} adi-cces-linux-add-in-${LINUXADDIN_VERSION}/accept-sla boolean true" | debconf-set-selections
cd ${PACKAGE_DIR}
dpkg -i adi-CrossCoreEmbeddedStudio-linux-x86-${CCES_VERSION}.deb
dpkg -i adi-LinuxAddinForCCES-linux-x86-${LINUXADDIN_VERSION}.deb