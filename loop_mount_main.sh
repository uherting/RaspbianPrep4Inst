#!/bin/bash

if [ "`whoami`" != "root" ]
then
  echo "NOTE: For execution of this script you need root use priviledges. Script stops here."
  exit 99
fi

#
# source: https://unix.stackexchange.com/questions/316401/how-to-mount-a-disk-image-from-the-command-line/430415#430415
#
# purpose: this script (un)mounts the image and its containing partitions

BNAME=`basename $0 .sh`
DNAME=`dirname $0`

GIVEN_VERSION=$1

. ${DNAME}/mod.conf

# if this script was called under its real name it just creates
# the sym links sudo_loop_mount_mnt and sudo_loop_mount_umnt which
# are to be used to mount the image on a loop device.
if [ "${BNAME}" == "loop_mount_main" ]
then
  echo "ERROR: do execute the sym links only!"
  exit 123
fi

if [ $# -lt 1 ]
then
  echo " "
  echo " "
  echo " "
  echo "Error: version expected (lite or desktop)"
  echo "Note: the image file is an optional parameter"
  echo "Usage ${BNAME}.sh <lite|desktop> <image_file>"
  exit 1
fi

if [ $# -gt 2 ]
then
  echo "Usage: more than two parameters are not allowed."
  exit 1
fi

VERSION=""
if [ "${GIVEN_VERSION}" == "lite" ]; then
  VERSION="-lite"
fi

if [ "${GIVEN_VERSION}" == "desktop" ]; then
  VERSION=""
fi

# check if given file exist 
# if no file name was given try to take the latest
# according to the timestamp in file in the directory ${IMG_LOCATION_EDIT}
# and the given version (lite|desktop)
if [ $# -eq 2 ]
then
  IMG_FILE=$1

  if [ ! -f ${IMG_FILE} ]
  then
    echo "Image file was not found: ${IMG_FILE}"
    exit 2 
  fi
else
  echo "Checking for newest image file according to the timestamp in file"
  if [ "${GIVEN_VERSION}" == "lite" ]; then
    # the lite version has the special marker '-lite' in the file name
    IMG_FILE=`ls ${IMG_LOCATION_EDIT}/*${VERSION}.img 2> /dev/null | sort | tail -n 1`
  else
    # the desktop version has no special marker in the file name
    IMG_FILE=`ls ${IMG_LOCATION_EDIT}/*${VERSION}.img 2> /dev/null | grep -v lite | sort | tail -n 1`
  fi

  if [ ! -f ${IMG_FILE} ]
  then
    echo "No image file found in directory ${IMG_LOCATION_EDIT}"
    exit 3 
  fi
fi

# mount the image and its containing partitions
if [ "${BNAME}" == "loop_mount_mnt" ]
then
  echo "Using image file ${IMG_FILE} for loop mounting."

  img=`readlink -f ${IMG_FILE}`
  #echo "The given file name of the image points to ${img}. If this is not correct please push CTRL-c."
  #echo "Otherwise push ENTER to continue."
  #read dummy_value

  # mount the img file on the next available loop device and assign the name of the device to a variable
  echo "The image file will be mounted on the following loop device:"
  # connecting the image file to a loop device and 
  dev="$(losetup --show -f -P "$img")"
  echo "$dev"

  # loop through the partitions contained in the img file and mount them to ${IMG_LOCATION_MOUNT}/<partition_name>
  echo "The mount points are as follows:"
  for part in "$dev"?*
  do
    if [ "$part" == "${dev}p*" ]; then
 echo "part $part == dev..."
      part="${dev}"
    fi
    dst="${IMG_LOCATION_MOUNT}/$(basename "$part")"
    #echo "partition: $part"
    #echo "mount point: $dst"
    echo "$dst"
    mkdir -p "$dst"
    mount "$part" "$dst"
  done
fi


# unmount the image and its containing partitions
if [ "${BNAME}" == "loop_mount_umnt" ]
then
  echo "Using image file ${IMG_FILE} for loop unmounting."

  # get resolved symbolic link or canonical file name
  img=`readlink -f ${IMG_FILE}`
  #echo "The given file name of the image points to ${img}. If this is not correct please push CTRL-c."
  #echo "Otherwise push ENTER to continue."
  #read dummy_value

  # define the loop device
  dev="`losetup -l | grep ${img} | cut -f1 -d\" \"`"

  # loop through the partitions presented through the loop dev and unmount them
  for part in "$dev"?*
  do
    if [ "$part" == "${dev}p*" ]; then
      part="${dev}"
    fi
    dst="${IMG_LOCATION_MOUNT}/$(basename "$part")"
    umount "$dst"
  done

  # detach loop device from img file
  losetup -d "$dev"

  # delete mount point directories
  rm -rf ${IMG_LOCATION_MOUNT}/*
fi


# What is intended by the use of the sym links pointing to this scripts?
# ======================================================================
#
# Here explanations by displaying what is done:
# ---------------------------------------------
# 1) mount the file to a loop device
# $ loop_mount_mnt /path/to/my/image/my.img (optional parameter)
# /dev/loop0
# /root/Raspi/ImageMount/loop0p1
# /root/Raspi/ImageMount/loop0p2
#
# $ ls /root/Raspi/ImageMount/loop0p1
# /whatever
# /files
# /youhave
# /there
#
# 2) proof of mounting activity by using "losetup -l"
# $ losetup -l
# NAME       SIZELIMIT OFFSET AUTOCLEAR RO BACK-FILE  DIO
# /dev/loop1         0      0         0  0 /full/path/to/my.img
#
# 3) umount the partitions and the img file
# $ # Cleanup.
# $ loop_mount_umnt /path/to/my/image/my.img (optional parameter)
# $ ls /root/Raspi/ImageMount/loop0p1
# $ ls /dev | grep loop0
# loop0
#

