#!/bin/sh

# Author: Cole McKnight
# Email: cbmckni@clemson.edu
# Organization: Clemson University HPC
# Github: https://github.com/cuhpc
# Last Updated: 2/23/19
# Description: CentOS Slurm installation. Base install(every node). 

# NOTE: Many commands need sudo permission. Run script as root or with sudo. Or just run each command one by one with sudo.

# Install Guide: https://www.slothparadise.com/how-to-install-slurm-on-centos-7-cluster/

# Variables:

export SLURM_VERSION=18.08.5 \
  && export MUNGE_UID=981 \
  && export SLURM_UID=982 


# Sync Slurm and Munge UID and GID for every node

groupadd -g $MUNGE_UID munge \
  && useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u $MUNGE_UID -g munge -s /sbin/nologin munge \
  && groupadd -g $SLURM_UID slurm \
  && useradd  -m -c "Slurm workload manager" -d /var/lib/slurm -u $SLURM_UID -g slurm -s /bin/bash slurm

# Update and install basic software

yum -y update \
  && yum -y install \
    sudo \
    wget \
    which \
    tree \
    munge \
    munge-libs \
    munge-devel \
    openssh-server \
    openssh-clients \
    mailx

# Next: slurm-db.sh
