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

# Install Guide: https://www.howtoforge.com/nfs-server-and-client-on-centos-7

# Variables:



# Install NFS

yum -y install nfs-utils

# Create shared dir 

mkdir -p /var/nfs-slurm
chmod -R 755 /var/nfs-slurm
chown nfsnobody:nfsnobody /var/nfs-slurm


# Start and enable NFS services

systemctl enable rpcbind \
  && systemctl enable nfs-server \
  && systemctl enable nfs-lock \
  && systemctl enable nfs-idmap \
  && systemctl start rpcbind \
  && systemctl start nfs-server \
  && systemctl start nfs-lock \
  && systemctl start nfs-idmap

cat > /etc/exports << EOF
/var/nfs-slurm    *(rw,sync,no_root_squash,no_all_squash)
/home            *(rw,sync,no_root_squash,no_all_squash)

EOF

# Start NFS

systemctl restart nfs-server

# Override firewall 

firewall-cmd --permanent --zone=public --add-service=nfs \
  && firewall-cmd --permanent --zone=public --add-service=mountd \
  && firewall-cmd --permanent --zone=public --add-service=rpc-bind \
  && firewall-cmd --reload
