#!/bin/sh -e

sleep 30

if [ -f /boot/log2ram.mk ]
then
  rm -f /boot/log2ram.mk
  /log2ram/install.sh 2>&1 >> /uh.log
  echo "log2ram installed" >> /uh.log
  echo "" >> /uh.log

  echo "Changing ownership of /home/pi ." >> /uh.log
  chown -R pi:pi /home/pi >> /uh.log

  echo "" >> /uh.log
fi

echo "" >> /uh.log
echo "" >> /uh.log
echo "" >> /uh.log

ifconfig >> /uh.log
echo "" >> /uh.log
dmesg >> /uh.log

echo "" >> /uh.log
echo "" >> /uh.log
echo "" >> /uh.log

if [ ! -f /boot/noresize ]
then
  # the presence of /boot/resized marks that the resize effort took already place
  if [ ! -f /boot/resized ]
  then
    echo "preparing for resizing file system while booting next time." >> /uh.log
    cp -a /boot/cmdline_resize.txt /boot/cmdline.txt 2>&1 >> /uh.log
  
    touch /boot/resized

    echo "About to reboot ..." >> /uh.log
    /sbin/reboot
  fi
fi

exit 0

