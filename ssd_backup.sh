#!/bin/bash

# This scripts writes content of the SSD to a backup area of the file system.

if [ "`whoami`" != "root" ]
then
  echo "NOTE: For execution of this script you need root use priviledges. Script stops here."
  exit 99
fi

BNAME=`basename $0 .sh`
DNAME=`dirname $0`

if [ $# -gt 0 ]; then
  echo " "
  echo " "
  echo " "
  echo "Error: no parameters expected"
  echo "Usage: ${BNAME}.sh <hostname>"
  exit 1
fi

. ${DNAME}/mod.conf

SSD_DEV="/dev/sdb"
SSD_SCRIPT="sfd_ssd.script"
SSD_SCRIPT_TPL="${SSD_SCRIPT}.tpl"

SSD_ROOTFS_MOUNT_POINT="`mount | grep ${SSD_DEV}2 | cut -f 3 -d " "`"
if [ "${SSD_ROOTFS_MOUNT_POINT}" == "" ] ; then
  echo "The SSD rootfs partition is not mounted on ${SSD_DEV}2"
  exit 77
fi

SSD_HOSTNAME="`head -n 1 ${SSD_ROOTFS_MOUNT_POINT}/etc/hostname | cut -f 1 -d " "`"
SSD_BACKUP_TARGET_DIR="${HOME_OF_BACKUPS_DIR}/${SSD_HOSTNAME}/${TS}_ssd"

echo "SSD_DEV: ${SSD_DEV}"
echo "SSD_HOSTNAME: ${SSD_HOSTNAME}"
echo "SSD_BACKUP_TARGET_DIR: ${SSD_BACKUP_TARGET_DIR}"
echo "TS: ${TS}"
echo " "

SSD_MOUNTED=1
for i in 1 2 ; do
  SSD_MOUNT_POINT=`mount | grep ${SSD_DEV}${i} | cut -f 3 -d " "`

  # target dir of back does certainly not exist, so let's create it
  mkdir -p ${SSD_BACKUP_TARGET_DIR}

  if [ $i -eq 1 ] ; then
    echo "Backing up boot partition"
    echo "SSD_MOUNT_POINT = ${SSD_MOUNT_POINT}"
    echo "rsync -r ${SSD_MOUNT_POINT} ${SSD_BACKUP_TARGET_DIR}"
    rsync -r ${SSD_MOUNT_POINT} ${SSD_BACKUP_TARGET_DIR}
    echo " "
  fi
  if [ $i -eq 2 ] ; then
    echo "Backing up rootfs partition"
    echo "SSD_MOUNT_POINT = ${SSD_MOUNT_POINT}"
    echo "rsync -a ${SSD_MOUNT_POINT} ${SSD_BACKUP_TARGET_DIR}"
    rsync -a ${SSD_MOUNT_POINT} ${SSD_BACKUP_TARGET_DIR}
    echo " "
  fi
done

if [ ${SSD_MOUNTED} -eq 1 ] ; then
  echo " "
  echo " "
  echo "ls -la ${SSD_BACKUP_TARGET_DIR}"
  ls -la ${SSD_BACKUP_TARGET_DIR}
fi


echo "unmounting SSD partitions of ${SSD_DEV}"
for i in `mount | grep ${SSD_DEV} | cut -f 1 -d " "`
do
  echo "unmount ${i}"
  umount ${i}
done

echo "task finished at `date`"


