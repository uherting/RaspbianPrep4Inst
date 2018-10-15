#!/bin/bash

BNAME=`basename $0 .sh`
DNAME=`dirname $0`

FILE_TO_WORK_ON=""

. ${DNAME}/mod_t.conf

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


function backupFiles() {
  local BASE_FILENAME=$1
  local nextInLineNumber=0
  local FILE_TO_WORK_ON=""
  local FILE_TO_WORK_MV_TGT=""


  for i in 4 3 2 1 0
  do
echo " "
echo "LOOP START"
echo "BASE_FILENAME = ${BASE_FILENAME}"
    FILE_TO_WORK_ON=$(getBackupFileName ${BASE_FILENAME} ${i})
    echo "FILE_TO_WORK_ON=${FILE_TO_WORK_ON}"

    if [ $i -eq 4 ]
    then
      if [ -f ${FILE_TO_WORK_ON} ]
      then
        echo "ACTION: rm -f ${FILE_TO_WORK_ON}"
        #rm -f ${FILE_TO_WORK_ON}
      else
        echo "ACTION: no action required"
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
  local FILE_NAME

  echo "START function customiseBoot"
  for FILE_NAME in /etc/dummytestval /etc/hosts
#  for i in 4 3 2 1 0
  do
    echo "FUNC backupFiles ${FILE_NAME}"
    backupFiles ${FILE_NAME}

#    FN=$(getBackupFileName ${FILE_NAME} 1)
#    echo "TEST FN = ${FN}"
#    FN=$(getBackupFileName ${FILE_NAME} 0)
#    echo "TEST FN = ${FN}"

#num=$(getNextNumber ${i})
#echo "num = ${num}"
  done
  echo "END function customiseBoot"

  return 0
}

customiseBoot

