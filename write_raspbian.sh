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

. ${DNAME}/mod.conf

if [ $# -gt 2 ]
then
  echo "Usage: more than two parameters are not allowed."
  exit 1
fi

if [ $# -eq 2 ]
then
  DEVICE_WR=$2
fi


# check if given file exist 
# if no file name was given try to take the latest
# according to the timestamp in file in the directory ${IMG_LOCATION_EDIT}
if [ $# -eq 1 ]
then
  IMG_FILE=$1

  if [ ! -f ${IMG_FILE} ]
  then
    echo "Image file was not found: ${IMG_FILE}"
    exit 2 
  fi
else
  echo "Checking for newest image file according to the timestamp in file"
  IMG_FILE=`ls ${IMG_LOCATION_EDIT}/*.img | sort | tail -n 1`

  if [ ! -f ${IMG_FILE} ]
  then
    echo "No image file found in directory ${IMG_LOCATION_EDIT}"
    exit 3 
  fi
fi


echo "${IMG_FILE} gets written to SD card at ${DEVICE_WR}"
#echo "In case this is not the image you want to be written or"
#echo "the intended target device please push CTRL-c to stop the process"
#echo "Otherwise push ENTER to start writing the image file ${IMG_FILE} to ${DEVICE_WR}"
#read dummy_value

echo "start at `date`"
time sudo dd bs=4M if=${IMG_FILE} of=${DEVICE_WR} status=progress
sync
echo "finished at `date`"

