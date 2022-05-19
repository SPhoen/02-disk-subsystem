#!/bin/bash

echo install mdadm
yum install mdadm mc nano -y

echo create RAID 5 from 4 disks
yes | mdadm --create --verbose /dev/md0 -l 5 -n 4 /dev/sd{b,c,d,e} 
echo add 2 hot spare disks
mdadm --add /dev/md0 /dev/sd{f,g}
echo save to /etc/mdadm/mdadm.conf
mkdir /etc/mdadm
touch /etc/mdadm/mdadm.conf
chmod 777 /etc/mdadm/mdadm.conf
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf

echo Create GPT
parted -s /dev/md0 mklabel gpt
echo Create partitions 
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%

echo create FS
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
echo Create directories
mkdir -p /raid/part{1,2,3,4,5}

echo Mount partitions
for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done



