#!/bin/bash

if [ "`whoami`" != "root" ]
then
  echo "NOTE: For execution of this script you need root use priviledges. Script stops here."
  exit 99
fi

BNAME=`basename $0 .sh`
DNAME=`dirname $0`

ADDITIONAL_CUSTOMISATION_SCRIPT="customise_details_additional.sh"

BOOT_DIR="boot"
ROOT_DIR="rootfs"

. ${DNAME}/mod.conf

if [ $# -lt 2 ]
then
  echo "Usage ${BNANE}.sh <hostname> <wifi|nowifi>"
  exit 1
fi

if [ $# -gt 2 ]
then
  echo "Usage ${BNANE}.sh <hostname> <wifi|nowifi>"
  exit 1
fi

HOSTNAME_NEW=$1
CREATE_WIFI_CREDENTIAL_FILE=1
if [ "$2" = "nowifi" ]
then
  CREATE_WIFI_CREDENTIAL_FILE=0
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
    echo "INSIDE BACKUP LOOP START with count=${i}"

    FILE_TO_WORK_ON=$(getBackupFileName ${BASE_FILENAME} ${i})
    echo "FILE_TO_WORK_ON=${FILE_TO_WORK_ON}"

    # If the backup file with count of 4 exists then we simply delete it 
    # as we want to keep a back log of 4 files only.
    # else
    # Determine the target file name and move (simple backup file) or
    # copy (original file) it. The original file is saved to a file 
    # which is created during the very first backup, so it represents the 
    # state of the original file before customising.
    if [ $i -eq 4 ]
    then
      if [ -f ${FILE_TO_WORK_ON} ]
      then
        echo "rm -f ${FILE_TO_WORK_ON}"
        rm -f ${FILE_TO_WORK_ON}
      else
        echo "ACTION: no action required as file does not exist (#${i})."
      fi
    else
      # get the number of the target file
      nextInLineNumber=$(getNextNumber $i)
      FILE_TO_WORK_MV_TGT=$(getBackupFileName ${BASE_FILENAME} ${nextInLineNumber})
      echo "FILE_TO_WORK_MV_TGT=${FILE_TO_WORK_MV_TGT}"
      if [ -f ${FILE_TO_WORK_ON} ]
       then
        if [ $i -gt 0 ]
        then
          echo "mv ${FILE_TO_WORK_ON} ${FILE_TO_WORK_MV_TGT}"
          mv ${FILE_TO_WORK_ON} ${FILE_TO_WORK_MV_TGT}
        else
          echo "cp -a ${FILE_TO_WORK_ON} ${FILE_TO_WORK_MV_TGT}"
          cp -a ${FILE_TO_WORK_ON} ${FILE_TO_WORK_MV_TGT}

          # backup original file to a one time copy file name
          FILE_TO_WORK_MV_TGT=$(getBackupFileName ${BASE_FILENAME} -1)
          if [ ! -e ${FILE_TO_WORK_MV_TGT} ]
          then
            echo "cp -a ${FILE_TO_WORK_ON} ${FILE_TO_WORK_MV_TGT}"
            cp -a ${FILE_TO_WORK_ON} ${FILE_TO_WORK_MV_TGT}
          fi
        fi
      else
        echo "ACTION: no action required as file does not exist (#${i})."
      fi
    fi
    echo "INSIDE BACKUP LOOP END"
  done
  
  return 0
}


function transferFilesPlusBackup() {
  SRC_FILE=$1
  TGT_FILE=$2

  # create none existing target dir
  TARGET_DIRNAME=`dirname ${TGT_FILE}`
  if [ ! -f ${TARGET_DIRNAME} ]
  then
    echo "Create new with : mkdir -p ${TARGET_DIRNAME}"
    mkdir -p ${TARGET_DIRNAME}
  fi

  # do a backup
  backupFiles ${TGT_FILE}

  # write the file using different methods for existing / none existing files
  if [ -f ${TGT_FILE} ]
  then
    echo "Create new content with: cat ${SRC_FILE} > ${TGT_FILE}"
    cat ${SRC_FILE} > ${TGT_FILE}
  else
    echo "Create new content with: cp -a ${SRC_FILE} ${TGT_FILE}"
    cp -a ${SRC_FILE} ${TGT_FILE}
  fi

  return 0
}


function customiseBoot() {
  ROOT_DIR_SOURCE=$1
  ROOT_DIR_TARGET=$2

  echo "ROOT_DIR_SOURCE = ${ROOT_DIR_SOURCE}"
  echo "ROOT_DIR_TARGET = ${ROOT_DIR_TARGET}"

  # transfer files in directories and files in the root dir of the boot partition
  for DIRNAME in /config.txt /cmdline.txt /cmdline_resize.txt /cmdline_normal.txt
  do
    if [ -d ${ROOT_DIR_SOURCE}${DIRNAME} ]
    then
      for FILE_NAME in `cd ${ROOT_DIR_SOURCE}${DIRNAME};find . -type f;cd - > /dev/null`
      do
        transferFilesPlusBackup ${ROOT_DIR_SOURCE}${DIRNAME}/${FILE_NAME} ${ROOT_DIR_TARGET}${DIRNAME}/${FILE_NAME}
      done
    else
      FILE_NAME=${DIRNAME}
      transferFilesPlusBackup ${ROOT_DIR_SOURCE}${FILE_NAME} ${ROOT_DIR_TARGET}${FILE_NAME}
    fi
  done

  # create empty files
  for FILE_NAME in /log2ram.mk /noresize /ssh 
  do
    if [ -f ${ROOT_DIR_SOURCE}/${FILE_NAME} ]
    then
      echo "touch ${ROOT_DIR_TARGET}/${FILE_NAME}"
      touch ${ROOT_DIR_TARGET}/${FILE_NAME}
    fi
  done

  # create wpa_supplicant.conf on the target if command line parameter
  # requires us to do so and if the file itself is existant
  # in the template dir as it is optional in case LAN is used
  TGT=${ROOT_DIR_TARGET}/wpa_supplicant.conf
  if [ ${CREATE_WIFI_CREDENTIAL_FILE} -eq 1 ]
  then
    if [ -f ${TGT} ]; then
      backupFiles ${TGT}
    fi
    if [ -f ${ROOT_DIR_SOURCE}/wpa_supplicant.conf ]; then
      echo "cat ${ROOT_DIR_SOURCE}/wpa_supplicant.conf > ${TGT}"
      cat ${ROOT_DIR_SOURCE}/wpa_supplicant.conf > ${TGT}
    fi
  else 
    if [ -f ${TGT} ]; then
      echo "no WiFi setup requested. Action: rm -f ${TGT}"
      rm -f ${TGT}
    fi
  fi

  return 0
}


function customiseRoot() {
  ROOT_DIR_SOURCE=$1
  ROOT_DIR_TARGET=$2

  echo "ROOT_DIR_SOURCE = ${ROOT_DIR_SOURCE}"
  echo "ROOT_DIR_TARGET = ${ROOT_DIR_TARGET}"

  # transfer files in directories and files in the root dir of the root partition
  for DIRNAME in /etc /home /root
  do
    if [ -d ${ROOT_DIR_SOURCE}${DIRNAME} ]
    then
      for FILE_NAME in `cd ${ROOT_DIR_SOURCE}${DIRNAME};find . -type f;cd - > /dev/null`
      do
        transferFilesPlusBackup ${ROOT_DIR_SOURCE}${DIRNAME}/${FILE_NAME} ${ROOT_DIR_TARGET}${DIRNAME}/${FILE_NAME}
      done
    else
      FILE_NAME=${DIRNAME}
      transferFilesPlusBackup ${ROOT_DIR_SOURCE}${FILE_NAME} ${ROOT_DIR_TARGET}${FILE_NAME}
    fi
  done

  # create tailor made files from template files in root partition
  for FILE_NAME in /etc/hostname /etc/hosts
  do
    # preparation
    FILE_IN="${ROOT_DIR_SOURCE}${FILE_NAME}"
    FILE_OUT="${ROOT_DIR_TARGET}${FILE_NAME}"

    # backup the file to be newly created
    backupFiles ${ROOT_DIR_TARGET}${FILE_NAME}

    # create the file from the template
    echo " "
    echo "creating ${FILE_OUT} from template ${FILE_IN}"
    echo "TEMPLATE: ${FILE_IN}"
    echo "FILE_OUT: ${FILE_OUT}"
    echo "sed -e \"s/YYYYYY/${HOSTNAME_NEW}/g\" < ${FILE_IN} > ${FILE_OUT}"
    sed -e "s/YYYYYY/${HOSTNAME_NEW}/g" < ${FILE_IN} > ${FILE_OUT}
  done

  # log2ram
  LOG2RAM_SRC="${ROOT_DIR_SOURCE}/log2ram"
  LOG2RAM_TGT="${ROOT_DIR_TARGET}/log2ram"
  if [ -d ${LOG2RAM_TGT} ]
  then
    echo "rm -rf ${LOG2RAM_TGT}"
    rm -rf ${LOG2RAM_TGT}
  fi

  echo "cp -a ${LOG2RAM_SRC} ${ROOT_DIR_TARGET}"
  cp -a ${LOG2RAM_SRC} ${ROOT_DIR_TARGET}
  echo "cat ${ROOT_DIR_SOURCE}/README_log2ram_UH.txt > ${ROOT_DIR_TARGET}"

  # README_log2ram_UH.txt
  FILE_NAME="/README_log2ram_UH.txt"
  backupFiles ${ROOT_DIR_TARGET}${FILE_NAME}
  echo "cat ${ROOT_DIR_SOURCE}/${FILE_NAME} > ${ROOT_DIR_TARGET}/${FILE_NAME}"
  cat ${ROOT_DIR_SOURCE}${FILE_NAME} > ${ROOT_DIR_TARGET}${FILE_NAME}
  echo "chmod 600 ${ROOT_DIR_TARGET}${FILE_NAME}"
  chmod 600 ${ROOT_DIR_TARGET}${FILE_NAME}

  # uh_script.sh
  FILE_NAME="/uh_script.sh"
  backupFiles ${ROOT_DIR_TARGET}${FILE_NAME}
  echo "cat ${ROOT_DIR_SOURCE}/${FILE_NAME} > ${ROOT_DIR_TARGET}/${FILE_NAME}"
  cat ${ROOT_DIR_SOURCE}${FILE_NAME} > ${ROOT_DIR_TARGET}${FILE_NAME}
  echo "chmod 700 ${ROOT_DIR_TARGET}${FILE_NAME}"
  chmod 700 ${ROOT_DIR_TARGET}${FILE_NAME}

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
chown -Rv root:root ${TEMPLATE_LOCATION_ROOT} > /dev/null
echo ""
echo ""

echo "Changing working dir to ${IMG_LOCATION_MOUNT}"
OLD_PWD=`pwd`
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

cd ${OLD_PWD} > /dev/null

echo "Changing ownership of template files back to original setting."
chown -Rv ${OLD_OWNER} ${TEMPLATE_LOCATION_ROOT} > /dev/null
echo ""
echo ""

exit 0

if [ -x ${ADDITIONAL_CUSTOMISATION_SCRIPT} ]
then
 echo "trying to execute additional customisation script"
 . ${DNAME}/${ADDITIONAL_CUSTOMISATION_SCRIPT}
 ADDITIONAL_CUSTOMISATION_EXIT_CODE=$?
 if [ ${ADDITIONAL_CUSTOMISATION_EXIT_CODE} -ne 0 ]
 then
   echo "additional customisation script ended with exit code ${ADDITIONAL_CUSTOMISATION_EXIT_CODE}."
 fi
fi
