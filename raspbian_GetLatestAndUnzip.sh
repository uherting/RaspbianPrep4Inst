#!/bin/bash

if [ "`whoami`" != "root" ]
then
  echo "NOTE: For execution of this script you need root use priviledges. Script stops here."
  exit 99
fi

BNAME=`basename $0 .sh`
DNAME=`dirname $0`

GIVEN_VERSION=$1
WGET_OUTPUT=wget_out.txt

. ${DNAME}/mod.conf

cd ${IMG_LOCATION_DOWNLOAD}
if [ $? -ne 0 ]
then
  echo "Problem with changing dir to ${IMG_LOCATION_DOWNLOAD} occured"
  exit 1
fi

if [ $# -lt 1 ]
then
  echo "version expected (lite or desktop)"
  exit 1
fi

VERSION=""
if [ "${GIVEN_VERSION}" == "lite" ]; then
  VERSION="_lite"
fi

if [ "${GIVEN_VERSION}" == "desktop" ]; then
  VERSION=""
fi

# delete all zip files in the current dir --- no 'old stuff' needed!
rm *.zip* *.img*

# get the latest Raspbian
# the file name will be the one the generic URL points to
wget --trust-server-names https://downloads.raspberrypi.org/raspbian${VERSION}_latest 2> ${WGET_OUTPUT}

# prepare the unzipping process and execute unzip
FILE_NAME=`grep 'Saving to: ‘' ${WGET_OUTPUT} | \
	sed -e "s/‘//g" -e "s/’//g" | \
	cut -f 3 -d " "`

echo "Downloaded file: ${FILE_NAME}"

echo "Unzipping file: ${FILE_NAME}"
unzip ${FILE_NAME}

echo "Move file: ${FILE_NAME} to ${IMG_LOCATION_DOWNLOAD_ARCHIVE}"
mv ${FILE_NAME} ${IMG_LOCATION_DOWNLOAD_ARCHIVE}

echo "Moving content of ${FILE_NAME} to ${IMG_LOCATION_EDIT}"
mv *.img ${IMG_LOCATION_EDIT}

