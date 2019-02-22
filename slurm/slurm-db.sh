#!/bin/sh

# Author: Cole McKnight
# Email: cbmckni@clemson.edu
# Organization: Clemson University HPC
# Github: https://github.com/cuhpc
# Last Updated: 2/23/19
# Description: CentOS Slurm installation. MariaDB install(database node). 

# NOTE: Many commands need sudo permission. Run script as root or with sudo. Or just run each command one by one with sudo.
# NOTE: Perform base install first! (slurm-base.sh)

# Install Guide: https://www.slothparadise.com/how-to-install-slurm-on-centos-7-cluster/

# Variables:

export HEADNODE=130.127.248.160 \ # Head node hostname
  && export DBNODE=130.127.248.161 \ # Database node hostname (This node)
  && export COMPUTENODES=('130.127.248.160' '130.127.248.161' '130.127.248.162' '130.127.248.163' '130.127.248.164' '130.127.248.165' '130.127.248.166' '130.127.248.167') # list of all node hostnames
  && export ROOTPASS=clemsontigers #root password for all nodes (be careful! delete after you are done)


# Install MariaDB 
 
yum -y install mariadb-server \
               mariadb-devel \
               sshpass

# Install rng-tools, create key 

yum -y install rng-tools \
  && rngd -r /dev/urandom \
  && /usr/sbin/create-munge-key -r \
  && dd if=/dev/urandom bs=1 count=1024 > /etc/munge/munge.key \
  && chown munge: /etc/munge/munge.key \
  && chmod 400 /etc/munge/munge.key

# Copy key to each compute node(all nodes in this case)

for i in "${COMPUTENODES[@]}"; 
do
  sshpass -p $ROOTPASS scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r /etc/munge/munge.key root@"$i":/etc/munge
  echo "$i key copied."
done

# ssh into each node and start munge

for i in "${COMPUTENODES[@]}"; 
do
  sshpass -p $ROOTPASS ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@"$i" \
    'chown -R munge: /etc/munge/ /var/log/munge/ && chmod 0700 /etc/munge/ /var/log/munge/ && systemctl enable munge && systemctl start munge'
  echo "$i munge started."
done

# Check if it's working

munge -n
munge -n | unmunge
for i in "${COMPUTENODES[@]}"; 
do
  munge -n | sshpass -p $ROOTPASS ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $i unmunge
  echo "$i munge running."
done
remunge


# Next: slurm-compute.sh
