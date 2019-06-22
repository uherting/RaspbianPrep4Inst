#!/bin/bash

# This scripts writes the latest image file to the SD card.
# The latest image is determined by the date/time stamp given in the file name.

if [ "`whoami`" != "root" ]
then
  echo "NOTE: For execution of this script you need root use priviledges. Script stops here."
  exit 99
fi

BNAME=`basename $0 .sh`
DNAME=`dirname $0`

if [ $# -lt 1 ]; then
  echo " "
  echo " "
  echo " "
  echo "Error: version expected (lite or desktop)"
  echo "Note: the image file is an optional parameter"
  echo "Usage: ${BNAME}.sh <lite|desktop> <image_file>"
  exit 1
fi

if [ $# -gt 2 ]
then
  echo "Usage: more than two parameters are not allowed."
  exit 1
fi

if [ $# -eq 1 ]; then
  ${DNAME}/loop_mount_mnt.sh $1
else
  ${DNAME}/loop_mount_mnt.sh $1 $2
fi

. ${DNAME}/mod.conf

SSD_DEV="/dev/sdb"
SSD_SCRIPT="sfd_ssd.script"
SSD_SCRIPT_TPL="${SSD_SCRIPT}.tpl"

# get label-id from cmdline.txt
CMDLINE_TXT=""
LABEL_ID=`tr " " "\n" < ${IMG_LOCATION_MOUNT}/*1/cmdline.txt | grep PARTUUID | cut -f 3 -d "=" | cut -f 1 -d "-"`

echo "IMG_LOCATION_MOUNT = ${IMG_LOCATION_MOUNT}"

# the file sfd_ssd.script was created by executing ...
# sfdisk --dump /dev/sdb > sfd_ssd.script
# and replacing the label-id / device name with 'LABEL_ID' / 'DEVICE'

# creating sfd_ssd.script with the correct label-id
echo "creating sfdisk script ${SSD_SCRIPT} from template file ${SSD_SCRIPT_TPL}"
sed \
  -e "s#LABEL_ID#${LABEL_ID}#g" \
  -e "s#DEVICE#${SSD_DEV}#g" \
  < ${SSD_SCRIPT_TPL} \
  > ${SSD_SCRIPT}
for i in `mount | grep ${SSD_DEV} | cut -f 1 -d " "`
do
  echo "unmount ${i}"
  umount ${i}
done

echo "executing sfdisk script ${SSD_SCRIPT} onto device ${SSD_DEV}"
time sfdisk ${SSD_DEV} < ${SSD_SCRIPT}

echo "creating file system on 1st partition of ${SSD_DEV}"
time mkfs.vfat -n"boot" ${SSD_DEV}1

echo "creating file system on 1st partition of ${SSD_DEV}"
time mkfs.ext4 -FL"rootfs" ${SSD_DEV}2

echo ""
echo ""
echo ""
echo "Please remove SSD and reattach it. After it is mounted please push the ENTER key."
read c

echo "copying files onto boot partition"
rsync -r ${IMG_LOCATION_MOUNT}/*1/* /media/uwe/boot

echo "copying files onto rootfs partition"
rsync -a ${IMG_LOCATION_MOUNT}/*2/* /media/uwe/rootfs

echo "LABEL_ID used: ${LABEL_ID}"
echo "DEVICE used: ${SSD_DEV}"

if [ $# -eq 1 ]; then
  ${DNAME}/loop_mount_umnt.sh $1
else
  ${DNAME}/loop_mount_umnt.sh $1 $2
fi

echo "task finished at `date`"


