BNAME=`basename $0 .sh`

if [ $# -ne 2 ]; then
  echo "Usage"
  echo "$0 hostname name_of_the_image"
  exit 99
fi

umount /dev/mmcblk0p1
umount /dev/mmcblk0p2

ADD_PARM=""
if [ ${BNAME} = "dd2image4GB" ];then
  ADD_PARM="count=4000"
fi

TS=`date +%Y%m%d_%H%M%S`

echo "doing the unmount of the mmc partitions"
umount /dev/mmcblk0p1
umount /dev/mmcblk0p2

of="${1}_${TS}__${2}.img"
echo "doing dd"
time dd bs=1M ${ADD_PARM} \
        if=/dev/mmcblk0 \
        of=${of} \
        status=progress

echo "doing bzip2"
time bzip2 ${of}
