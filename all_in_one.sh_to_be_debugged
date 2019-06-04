#!/bin/bash

if [ "`whoami`" != "root" ]
then
  echo "NOTE: For execution of this script you need root use priviledges. Script stops here."
  exit 99
fi

BNAME=`basename $0 .sh`
DNAME=`dirname $0`

if [ $# -lt 3 ]
then
  echo "Usage ${BNANE}.sh <lite|desktop> <hostname> <wifi|nowifi>"
  exit 1
fi

GIVEN_VERSION=$1
GIVEN_HOSTNAME=$2
GIVEN_WIFI_SETTING=$3

. ${DNAME}/mod.conf

echo " "
echo " "
echo " "


#echo "unzip image"
#cd ../ImageEdit
#rm /root/Raspi/ImageEdit/2018-11-13-raspbian-stretch.img
#time unzip ../Downloads/archive/2018-11-13-raspbian-stretch.zip
#cd -

time ${DNAME}/raspbian_GetLatestAndUnzip.sh ${GIVEN_VERSION}
time ${DNAME}/loop_mount_mnt.sh ${GIVEN_VERSION}
time ${DNAME}/customise_details.sh ${GIVEN_HOSTNAME} ${GIVEN_WIFI_SETTING}
time ${DNAME}/loop_mount_umnt.sh ${GIVEN_VERSION}
time ${DNAME}/write_raspbian.sh 

echo " "
echo " "
echo " "

