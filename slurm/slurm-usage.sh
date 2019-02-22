#!/bin/sh

# Author: Cole McKnight
# Email: cbmckni@clemson.edu
# Organization: Clemson University HPC
# Github: https://github.com/cuhpc 
# Last Updated: 2/24/19
# Description: CentOS Slurm basic usage

# NOTE: Many commands need sudo permission. Run script as root or with sudo. Or just run each command one by one with sudo.

# Prereqs: (MUST be done prior on respective nodes)

# pi-prep.sh
# centos-nfs-server.sh
# centos-nfs-client.sh
# slurm-base.sh
# slurm-db.sh
# slurm-compute.sh
# slurm-install.sh

# Install Guide: https://www.slothparadise.com/how-to-install-slurm-on-centos-7-cluster/

# Variables:

export NUMNODES=8

# Show Nodes

scontrol show nodes

# List nodes' status

sinfo -lN

# Run simple hostname job

srun -N$NUMNODES /bin/hostname
