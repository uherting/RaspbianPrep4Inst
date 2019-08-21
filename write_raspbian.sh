#!/bin/bash

# This scripts writes the latest image file to the SD card.
# The latest image is determined by the date/time stamp given in the file name.

if [ "`whoami`" != "root" ]; then
  echo "NOTE: For execution of this script you need root use priviledges. Script stops here."
  exit 99
fi

BNAME=`basename $0 .sh`
DNAME=`dirname $0`

. ${DNAME}/mod.conf

if [ $# -gt 2 ]; then
  echo "Usage: ${BNAME}.sh <write_image_yn> <image_file> <target_device>"
  echo "       Parameter <write_image_yn>: either 'y' or 'n'. Allows / permits writing to SD card"
  echo "       More than three parameters are not allowed."
  echo "       Parameters #2 and #3 are optional."
  echo "       If you want to supply the <target_device> then you have to supply the <image_file>, too."
  exit 1
fi

WRITE_IMG=0
if [ "${1}" == "y" ]; then
  WRITE_IMG=1
fi

# check if given file exist 
# if no file name was given try to take the latest
# according to the timestamp in file in the directory ${IMG_LOCATION_EDIT}
if [ $# -gt 1 ]; then
  IMG_FILE=$2

  if [ ! -f ${IMG_FILE} ]; then
    echo "Image file was not found: ${IMG_FILE}"
    exit 2 
  fi
else
  echo "Checking for newest image file according to the timestamp in file"
  IMG_FILE=`ls ${IMG_LOCATION_EDIT}/*.img | sort | tail -n 1`

  if [ ! -f ${IMG_FILE} ]; then
    echo "No image file found in directory ${IMG_LOCATION_EDIT}"
    exit 3 
  fi
fi

if [ $# -eq 3 ]; then
  DEVICE_WR=$3
fi

# check whether the target device exists
if [ -e ${DEVICE_WR} ]; then
  # unmount recently inserted card if necessary
  if [ -e ${DEVICE_WR}p1 ]; then
    umount ${DEVICE_WR}p1
  fi
  if [ -e ${DEVICE_WR}p2 ]; then
    umount ${DEVICE_WR}p2
  fi

  # write at all?
  if [ ${WRITE_IMG} -eq 0 ]; then
    echo "No writing to the SD card takes place as requested by parameter #1."
    echo "The following command would have been used:"
    echo "dd bs=4M if=${IMG_FILE} of=${DEVICE_WR} status=progress"
  else
    echo "${IMG_FILE} gets written to SD card at ${DEVICE_WR}"
    echo " "
    echo "Writing to ${DEVICE_WR} starts in 10 seconds"
    echo " "
    echo "The following command will be used:"
    echo "dd bs=4M if=${IMG_FILE} of=${DEVICE_WR} status=progress"

    sleep 10 

    echo "start at `date`"

    time dd bs=4M if=${IMG_FILE} of=${DEVICE_WR} status=progress
    sync
  fi
fi

if [ ! -e ${DEVICE_WR} ]; then
  echo "ERROR: the device ${DEVICE_WR} does not exist."
fi

echo "finished at `date`"

