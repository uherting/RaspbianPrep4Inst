BNAME=`basename $0 .sh`

if [ $# -le 3 ]; then
  echo "Usage"
  echo "$0 name_of_the_image output_dev [compress_image_YN]" 
  exit 99
fi

TS=`date +%Y%m%d_%H%M%S`

if=$1
of=$2
echo "doing dd"
time dd bs=1M ${ADD_PARM} \
        if=${if} \
        of=${of} \
        status=progress

if [ $# -eq 3 ]; then
  echo "doing bzip2"
  time bzip2 ${of}
fi
