#!/bin/bash

if [ "`whoami`" != "root" ]
then
  echo "NOTE: For execution of this script you need root use priviledges. Script stops here."
  exit 99
fi

BNAME=`basename $0 .sh`
DNAME=`dirname $0`

HOSTNAME_NEW=$1

ADDITIONAL_CUSTOMISATION_SCRIPT="myVeryOwnCustScript.sh"


#TGT_ROOT_DIR="/root/Raspi_UH/headless_install/zero"

BOOT_DIR="boot"
ROOT_DIR="rootfs"

. ${DNAME}/mod.conf

if [ $# -lt 1 ]
then
  echo "hostname expected"
  exit 1
fi

FILE_TO_WORK_ON=""

# function declaration follows
function getNextNumber() {
  local retVal=$1
  ((retVal++))
  echo "${retVal}"
}


function getBackupFileName () {
  local BASE_FILENAME_BAK="$1"
  local PREFIX="_bak.${2}"

  # original file name given
  if [ $2 -eq 0 ]
  then
    PREFIX=""
  fi

  # backup original file to a one time copy file name
  if [ $2 -eq -1 ]
  then
    PREFIX="_UH.orgFile"
  fi

  echo "${BASE_FILENAME_BAK}${PREFIX}"
}

# backup existing files to make space for new content
function backupFiles() {
  local BASE_FILENAME=$1
  local nextInLineNumber=0
  local FILE_TO_WORK_ON=""
  local FILE_TO_WORK_MV_TGT=""

  #echo "BASE_FILENAME = ${BASE_FILENAME}"

  for i in 4 3 2 1 0
  do
echo " "
echo "LOOP START"
    FILE_TO_WORK_ON=$(getBackupFileName ${BASE_FILENAME} ${i})
    echo "FILE_TO_WORK_ON=${FILE_TO_WORK_ON}"

    if [ $i -eq 4 ]
    then
      if [ -f ${FILE_TO_WORK_ON} ]
      then
        echo "ACTION: rm -f ${FILE_TO_WORK_ON}"
        #rm -f ${FILE_TO_WORK_ON}
      fi
    else
      nextInLineNumber=$(getNextNumber $i)
      FILE_TO_WORK_MV_TGT=$(getBackupFileName ${BASE_FILENAME} ${nextInLineNumber})
      echo "FILE_TO_WORK_MV_TGT=${FILE_TO_WORK_MV_TGT}"
      if [ -f ${FILE_TO_WORK_ON} ]
       then
        if [ $i -gt 0 ]
        then
          echo "ACTION: mv ${FILE_TO_WORK_ON} ${FILE_TO_WORK_MV_TGT}"
          #mv ${FILE_TO_WORK_ON} ${FILE_TO_WORK_MV_TGT}"
        else
          echo "ACTION: cp -a ${FILE_TO_WORK_ON} ${FILE_TO_WORK_MV_TGT}"
          #cp -a ${FILE_TO_WORK_ON} ${FILE_TO_WORK_MV_TGT}"

          # backup original file to a one time copy file name
          FILE_TO_WORK_MV_TGT=$(getBackupFileName ${BASE_FILENAME} -1)
          if [ ! -e ${FILE_TO_WORK_MV_TGT} ]
          then
            echo "ACTION: cp -a ${FILE_TO_WORK_ON} ${FILE_TO_WORK_MV_TGT}"
            #cp -a ${FILE_TO_WORK_ON} ${FILE_TO_WORK_MV_TGT}"
          fi
        fi
      else
          echo "ACTION: no action required"
      fi
    fi
echo "LOOP FINISH"
  done
  
  return 0
}


function customiseBoot() {
  ROOT_DIR_SOURCE=$1
  ROOT_DIR_TARGET=$2
echo "ROOT_DIR_SOURCE = ${ROOT_DIR_SOURCE}"
echo "ROOT_DIR_TARGET = ${ROOT_DIR_TARGET}"

  # /config.txt
  # /ssh 
  echo "touch ${ROOT_DIR_TARGET}/ssh"

if [ 1 -eq 1 ]
then
  # create tailor made files from template files in boot partition
  for FILE_NAME in /config.txt
  do
    # backup existing files to make space for new content
    #backupFiles ${ROOT_DIR_TARGET}${FILE_NAME}

    # create the file from the template or otherwise ...
    #foobar....

echo ""
  done
else
  echo "The real customiseBoot functionality was not executed."
fi
  return 0
}


function customiseRoot() {
  ROOT_DIR_SOURCE=$1
  ROOT_DIR_TARGET=$2
echo "ROOT_DIR_SOURCE = ${ROOT_DIR_SOURCE}"
echo "ROOT_DIR_TARGET = ${ROOT_DIR_TARGET}"

  # create tailor made files from template files in root partition
  for FILE_NAME in /etc/hostname /etc/hosts
  do
    # preparation
    FILE_IN="${ROOT_DIR_SOURCE}${FILE_NAME}"
    FILE_OUT="${ROOT_DIR_TARGET}${FILE_NAME}"

    # backup the file to be newly created
    #backupFiles ${ROOT_DIR_TARGET}${FILE_NAME}

    # create the file from the template
    echo " "
    echo "creating ${FILE_OUT} from template ${FILE_IN}"
    echo "TEMPLATE: ${FILE_IN}"
    echo "FILE_OUT: ${FILE_OUT}"
    #sed -e "s/YYYYYY/${HOSTNAME_NEW}/g" < ${FILE_IN} > ${FILE_OUT}
    echo "sed -e \"s/YYYYYY/${HOSTNAME_NEW}/g\" < ${FILE_IN} > ${FILE_OUT}"
  done

  return 0
}


#
#
# now the "real" thing: 
# execution of main functions for 
# customising boot and root partition
#
#
echo "Changing ownership of template files to root."
OLD_OWNER=`ls -l ${TEMPLATE_LOCATION_ROOT} | tail -n1 | cut -f 3-4 -d " " | tr " " ":"`
chown -Rv root:root ${TEMPLATE_LOCATION_ROOT}
echo ""
echo ""

echo "Changing working dir to ${IMG_LOCATION_MOUNT}"
cd ${IMG_LOCATION_MOUNT} 2> /dev/null
echo "We are now in the dir `pwd`."
echo ""
echo ""


for partition in 1 2
do

  BASE_DIR_EDIT=`ls -d *p${partition}`

  # boot
  if [ ${partition} -eq 1 ]
  then
    echo " "
    echo "====================== B O O T =============================="
    echo " "
    echo " "
    echo "Customising boot partition (partition ${partition})"
    echo " "
    echo "BASE_DIR_EDIT = ${BASE_DIR_EDIT}"
    echo " "
    customiseBoot ${TEMPLATE_LOCATION_ROOT} ${IMG_LOCATION_MOUNT}/${BASE_DIR_EDIT}
    echo " "
    echo " "
    echo "====================== R O O T =============================="
    echo " "
    echo " "
  fi

  # root
  if [ ${partition} -eq 2 ]
  then
    echo " "
    echo "Customising root partition (partition ${partition})"
    echo "BASE_DIR_EDIT = ${BASE_DIR_EDIT}"
    echo " "
    customiseRoot ${TEMPLATE_LOCATION_ROOT} ${IMG_LOCATION_MOUNT}/${BASE_DIR_EDIT}
    echo " "
    echo " "
    echo "============================================================="
  fi
done

cd - > /dev/null

echo "Changing ownership of template files back to original setting."
chown -Rv ${OLD_OWNER} ${TEMPLATE_LOCATION_ROOT}
echo ""
echo ""

exit 0

if [ -x ${ADDITIONAL_CUSTOMISATION_SCRIPT} ]
then
 echo "trying to execute additional customisation script"
 ${ADDITIONAL_CUSTOMISATION_SCRIPT}
 ADDITIONAL_CUSTOMISATION_EXIT_CODE=$?
 if [ ${ADDITIONAL_CUSTOMISATION_EXIT_CODE} -ne 0 ]
 then
   echo "additional customisation script ended with exit code ${ADDITIONAL_CUSTOMISATION_EXIT_CODE}."
 fi
fi
