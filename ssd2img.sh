#
#
#
#     To be improved!!!
#
#
#

# create a target for the SSD data
cd ${HOME}/Raspi/ImageEdit
cp -a 2019-04-08-raspbian-stretch.img 2019-06-22-raspbian-stretch.img

# ???
mv 2019-04-08-raspbian-stretch.img pidash128

# ???
cd ../RaspbianPrep4Inst
./loop_mount_mnt.sh desktop

# empty the rootfs and boot directories 
cd ${HOME}/Raspi/ImageMount
rm -rf loop?p?/*

#copy data from the SSD to the mounted image
for dev in 1 2
do
  SSD_PART="/dev/sdb${dev}"
  SSD_MOUNTPOINT=`mount | grep ${SSD_PART} | cut -f 3 -d " "`
  echo "${SSD_PART} is mounted on ${SSD_MOUNTPOINT}"
  LCL_DIR=`ls -d /root/Raspi/ImageMount/*${dev}`
  echo "LCL_DIR = ${LCL_DIR}"
  echo ""
  if [ "${dev}" == "1" ] ; then
    echo "rsync -r ${SSD_MOUNTPOINT}/* ${LCL_DIR}"
    time rsync -r ${SSD_MOUNTPOINT}/* ${LCL_DIR}
  fi
  if [ "${dev}" == "2" ] ; then
    echo "rsync -a ${SSD_MOUNTPOINT}/* ${LCL_DIR}"
    time rsync -a ${SSD_MOUNTPOINT}/* ${LCL_DIR}
  fi
done
