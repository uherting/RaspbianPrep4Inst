#!/bin/sh -e

echo "The last booting occured at `date`" > /uh.log

if [ -f /boot/log2ram.mk ]
then
  rm -f /boot/log2ram.mk
  /log2ram/install.sh 2>&1 >> /uh.log
  echo "log2ram installed" >> /uh.log
fi

echo "" >> /uh.log
echo "" >> /uh.log

if [ ! -f /boot/chown_pi_done ]
then
  echo "Changing ownership of /home/pi ." >> /uh.log
  chown -R pi:pi /home/pi >> /uh.log
  touch /boot/chown_pi_done
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
    if [ -f /boot/cmdline_resize.txt ]; then
      echo "preparing for resizing file system while booting next time." >> /uh.log
      # does not work: cat /boot/cmdline_resize.txt > /boot/cmdline.txt 2>&1 >> /uh.log
      cat /boot/cmdline_resize.txt > /boot/cmdline.txt | tee -a /uh.log
  
      touch /boot/resized
    else
      echo "The file /boot/cmdline_resize.txt is missing. Cannot prepare for resize. The file /boot/noresize will be created again." >> /uh.log
      touch /boot/noresize
    fi
  fi
fi

