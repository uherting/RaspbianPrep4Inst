#!/bin/bash

if [ "`whoami`" != "root" ]
then
  echo "NOTE: For execution of this script you need root use priviledges. Script stops here."
  exit 99
fi

BNAME=`basename $0 .sh`
DNAME=`dirname $0`

if [ $# -lt 4 ]
then
  echo "Usage ${BNAME}.sh <write_image_yn> <lite|desktop> <hostname> <wifi|nowifi> "
  echo ""
  echo "Parameter <write_image_yn>: either 'y' or 'n'. Allows / permits writing to SD card"
  exit 1
fi

WRITE_IMG=$1
GIVEN_VERSION=$2
GIVEN_HOSTNAME=$3
GIVEN_WIFI_SETTING=$4

. ${DNAME}/mod.conf

echo " "
echo " "
echo " "


# debugging only:
#echo "unzip image"
#cd ../ImageEdit
#rm /root/Raspi/ImageEdit/2018-11-13-raspbian-stretch.img
#time unzip ../Downloads/archive/2018-11-13-raspbian-stretch.zip
#cd -

time ${DNAME}/raspbian_GetLatestAndUnzip.sh ${GIVEN_VERSION}
time ${DNAME}/loop_mount_mnt.sh ${GIVEN_VERSION}
time ${DNAME}/customise_details.sh ${GIVEN_HOSTNAME} ${GIVEN_WIFI_SETTING}
time ${DNAME}/loop_mount_umnt.sh ${GIVEN_VERSION}
time ${DNAME}/write_raspbian.sh ${WRITE_IMG}

echo " "
echo " "
echo " "

