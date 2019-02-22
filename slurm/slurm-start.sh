#!/bin/sh

# Author: Cole McKnight
# Email: cbmckni@clemson.edu
# Organization: Clemson University HPC
# Github: https://github.com/cuhpc 
# Last Updated: 2/24/19
# Description: CentOS Slurm Installation. 

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

export SLURM_VERSION=18.08.5-2 \
  && export MUNGE_UID=981 \
  && export SLURM_UID=982 \
  && export ARCH=armv7hl \ # system architecture (ex. ARM for RaspPi)
  && export COMPUTENODES=('130.127.248.160' '130.127.248.161' '130.127.248.162' '130.127.248.163' '130.127.248.164' '130.127.248.165' '130.127.248.166' '130.127.248.167') \ # list of all node hostnames
  && export ROOTPASS=clemsontigers \ #root password for all nodes (be careful! delete after you are done)
  && export DBNODE=130.127.248.161 \ # Database node hostname
  && export HEADNODE=130.127.248.160 # Head node hostname

# ssh into each node and check config

for i in "${COMPUTENODES[@]}"; 
do
  if [ "$i" == "$HEADNODE" ]
  then
    sshpass -p $ROOTPASS ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@"$i" \
      'mkdir -p /var/spool/slurmctld \
         && chown slurm: /var/spool/slurmctld \
         && chmod 755 /var/spool/slurmctld \
         && touch /var/log/slurmctld.log \
         && chown slurm: /var/log/slurmctld.log \
         && touch /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log \
         && chown slurm: /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log' 
  fi
  sshpass -p $ROOTPASS ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@"$i" \
    'mkdir -p /var/spool/slurmd \
       && chown slurm: /var/spool/slurmd \
       && chmod 755 /var/spool/slurmd \
       && touch /var/log/slurmd.log \
       && chown slurm: /var/log/slurmd.log \
       && slurmd -C \
       && systemctl stop firewalld \
       && systemctl disable firewalld \
       && yum install ntp -y \
       && chkconfig ntpd on \
       && ntpdate pool.ntp.org \
       && systemctl start ntpd \
       && chmod g-w /var/log \
       && chown slurm /var/spool/slurmd \
       && chgrp slurm /var/spool/slurmd'
  echo "$i Slurm configured."
done

# Start Slurmd on each node

for i in "${COMPUTENODES[@]}"; 
do
  sshpass -p $ROOTPASS ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@"$i" \
    'systemctl enable slurmd.service \
     &&  systemctl restart slurmd.service \
     &&  systemctl status slurmd.service'
  echo "$i Slurm started."
done

# Start slurmdbd on database node

sshpass -p $ROOTPASS ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@"$DBNODE" \
      'mkdir -p /var/spool/slurm/d \
         /var/log/slurm \
         && chown slurm: /var/spool/slurm/d \
         /var/log/slurm \
         && /usr/sbin/slurmdbd'
 
# Start slurmctld on head node

systemctl enable slurmctld.service
systemctl restart slurmctld.service
systemctl status slurmctld.service


