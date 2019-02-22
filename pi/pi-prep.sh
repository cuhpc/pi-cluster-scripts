#!/bin/sh

# Author: Cole McKnight
# Email: cbmckni@clemson.edu
# Organization: Clemson University HPC
# Github: https://github.com/cuhpc
# Last Updated: 2/23/19
# Description: Raspberry Pi 3 Prep for HPC cluster. 

# NOTE: Many commands need root permission. Run script as root.

# Image: http://altarch.centos2.zswap.net/7.6.1810/isos/armhfp/CentOS-Userland-7-armv7hl-RaspberryPI-Minimal-1810-sda.raw.xz
# Guide: https://wiki.centos.org/SpecialInterestGroup/AltArch/armhfp

# Variables:

FIRSTUSER=cole # your name
HOST=pi0 # desired hostname for node

# After first boot: 

# Expand root FS to full SD space

/usr/bin/rootfs-expand

# Set hostname

hostnamectl set-hostname $HOST

# Create sudo user

adduser $FIRSTUSER
passwd $FIRSTUSER
usermod -aG wheel $FIRSTUSER

# Add special ARM EPEL repo. MUST be run as root (not sudo)

cat > /etc/yum.repos.d/epel.repo << EOF
[epel]
name=Epel rebuild for armhfp
baseurl=https://armv7.dev.centos.org/repodir/epel-pass-1/
enabled=1
gpgcheck=0

EOF

yum -y install epel-rpm-macros

# Update and install basic software

yum -y update \
  && yum -y install \
    epel-release \
  && yum -y install \
  sudo \
  wget \
  which \
  tree \
  git \
  nano 

# reboot to use new kernel


