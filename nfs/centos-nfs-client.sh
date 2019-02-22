#!/bin/sh

# Author: Cole McKnight
# Email: cbmckni@clemson.edu
# Organization: Clemson University HPC
# Github: https://github.com/cuhpc
# Last Updated: 2/23/19
# Description: CentOS NFS server installation. 

# NOTE: Many commands need sudo permission. Run script as root or with sudo. Or just run each command one by one with sudo.

# Prereqs: (MUST be done prior on respective nodes)

# pi-prep.sh
# centos-nfs-server.sh

# Install Guide: https://www.howtoforge.com/nfs-server-and-client-on-centos-7

# Variables:

export SERVERHOST=130.127.248.161 # Hostname of server running NFS

# Install NFS 

yum -y install nfs-utils

# Create shared directories

mkdir -p /mnt/nfs/home
mkdir -p /mnt/nfs/var/nfs-slurm

# Mount to server

mount -t nfs $SERVERHOST:/home /mnt/nfs/home/
mount -t nfs $SERVERHOST:/var/nfs-slurm /mnt/nfs/var/nfs-slurm/

# Check volume 

df -kh

# Make mount permanent(survives reboot)

echo ''"$SERVERHOST"':/home    /mnt/nfs/home   nfs defaults 0 0' >> /etc/fstab
echo ''"$SERVERHOST"':/var/nfs-slurm    /mnt/nfs/var/nfs-slurm   nfs defaults 0 0' >> /etc/fstab
