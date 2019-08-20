About this project
==================
This project was born out of a need to have a standard process to prepare the headless installation of Raspbian Stretch onto a Raspberry Pi. With the help of the scripts from this project an image of Raspbian can be downloaded, customised and written to a storage card. as I (and maybe you, too) like to control the process I separated the functionality into several scripts with a common configuration file. Even a custom script (maybe yours?) can be executed from the custimisation script.

Most of Raspberry Pies I own are of the type Zero W and as I run them headlessly I used the lite version of Raspbian in the beginning for this project, but the same steps described here can be used to prepare a desktop image file. You will find scripts who ask for lite or desktop to address this.
 
I strongly rely on the fine work of the Raspberry foundation (https://www.raspberrypi.org) whose image files I use for my customisation. See https://www.raspberrypi.org/downloads/raspbian/ for details on the distribution.

What is done 
============
* downloading the latest Raspbian Image
* decompressing the image file
* mounting the image file in order to add / modify files
* customisation
  - applying a host name
  - adding WiFi credentials based on file in the Templates directory of the repository if requested
  - enabling SSH
  - 
* further customising by an optinal custom script which is executed in case of existance

There are a few scripts handling the entire  process. This gives you 
control of the process if you want to add more info / skip a step etc.

What to consider
================
Prior to applying the customisation script you might consider the following ideas

* Do I want a fully fledged desktop version of Raspbian on my Raspberry Pi?
  There is the desktop and the lite image to select from.

* Do I want to log to RAM? If the file Templates/log2ram.mk exists the snapshot of 
  log2ram (for details see https://github.com/azlux/log2ram) is installed. 

  If you create the file log2ram.mk in the boot partition on the storage card 
  after booting the OS the log2ram application is installed from the 
  directory /log2ram in the root partition ready to be used after the next booting
  of the Raspberry Pi.

* Shall the entire storage card be used? It might be nice to have a small 
  footprint for testing some things. As soon as the file Templates/noresize 
  exists, the resizing will not occur as part of the booting of the Raspberry Pi.

  If you delete the file in the boot partition on the storage card after 
  the Raspberry Pi booted the resize process will be executed on the next boot.

  Please pay attention to the fact that the process of resizing the file 
  system cannot be reversed.

* Is the Raspberry Pi connected to the Router via WiFI? In case you want to 
  create the file Templates/wpa_supplicant.conf using the template 
  Templates/wpa_supplicant.conf_example to suit your needs (country, 
  SSID and PSK).

The files described above are created in the boot partition of the image by 
means are written later onto the storage card. 

How to get started
==================

First think whether the partition which is mounted on / holds sufficient space for the downloaded image (lite:360MB / desktop:1365MB) and the decompressed image file (lite:1780MB / desktop:3944MB). If this is an issue you might consider to create a directory on an appropriate partition and make /root/Raspi a symlink to it.

How to setup 
* sudo -i (become root)
* two options here
  - mkdir /root/Raspi (create the directory where everything will take place if there is enough space on the partition holding /root)
  - otherwise consider to create a directory on an appropriate partition and make /root/Raspi a symlink to it
* cd /root/Raspi (change working directory to where everything will take place)
* git clone https://github.com/uherting/RaspbianPrep4Inst.git (fetch the content of this repositority)

Now the environment is prepared. 

Introduction to the shell scripts
=================================

The scripts are thought to be helper scripts for downloading, customising,
and writing an image of the Linux distribution Raspbian to a SD card.
Additional Customisation can be done through a script you supply, see 
section "Additional Customisation" for details.

Order of execution
------------------
Here are the actions and the commands plus some explanation on the tasks / results.

1) Downloading: "./raspbian_GetLatestAndUnzip.sh <lite|desktop>"
   The latest version of Raspbian will get downloaded to the directory 
   ${IMG_LOCATION_DOWNLOAD} defined in the file mod.conf. The parameter 
   determines whether the lite (no GUI) or desktop version will be downloaded.

   The file name will be something like "2018-06-27-raspbian-stretch-lite.zip".
   The URL used for the retrieval is generic and so it will - hopefully - work
   with the next major release(s) after Raspbian Stretch.

   The downloaded file will be decompressed. After being decompressed it 
   will be moved to the ${IMG_LOCATION_DOWNLOAD_ARCHIVE} directory while 
   the extracted file goes into the ${IMG_LOCATION_EDIT} directory.

2) Mounting the image: "./loop_mount_mnt.sh <lite|desktop> <image_file>" 
   (the image file name is optional)

   This mounts the latest image file (according to the timestamp in file
   in the directory ${IMG_LOCATION_EDIT}). If an image file name is given
   it will be used instead.
   
   The partitions contained in the image file can be found in the directory 
   ${IMG_LOCATION_MOUNT}/* .

3) Writing customisation to the mounted image: "./customise_details.sh <hostname> <wifi|nowifi>"
   This script is the heart of the project. It modifies some files 
   contained in the image file and adds a few more. 

   The parameter <hostname> is used to change the original initial 
   hostname from "raspberrypi" to the given string.

   The parameter <wifi|nowifi> is used to determine whether the file 
   wpa_supplicant.conf containing the WiFi credentials is transferred 
   to the boot partition. The file wpa_supplicant.conf has to be created
   in the directory 'Templates' which is a subdirectory of the location 
   where the scripts are located. You may copy the file 
   wpa_supplicant.conf and edit it according to your needs.

   An addtional customisation script called 'customise_details_additional' 
   can be supplied by you in order to apply your very own customisation.
   The script is executed in the context of the script 'customise_details.sh'
   and does not need any execute rights set.

4) Unmounting the image: "./loop_mount_umnt.sh <lite|desktop> <image_file>" 
   (the image file name is optional)

   This unmounts the latest image file (according to the timestamp in file
   in the directory ${IMG_LOCATION_EDIT}). If an image file name is given
   it will be used instead.

5) Writing the image to the SD card: 
   "./write_raspbian.sh <write_image_yn> <image filename> <SD card device>"

   This script writes an image file to the SD card. The parameters 
   are optional.

   Parameter <write_image_yn>: either 'y' or 'n'. Allows / permits writing to SD card.
   
   This writes the latest image file (according to the timestamp in file
   in the directory ${IMG_LOCATION_EDIT}) or the image file given on 
   command line.

   Please bear in mind that none of the partitions should be mounted for 
   any reason before executing this script. You may have to unmount the 
   partitions manually.

   Note: If you want to supply the <SD card device> then you have to 
   supply the <image filename>, too.

Example of a run:
 ./raspbian_GetLatestAndUnzip.sh lite
 ./loop_mount_mnt.sh lite
 ./customise_details.sh pizc141 wifi
 ./loop_mount_umnt.sh lite
 ./write_raspbian.sh y

Additional Customisation
------------------------
The image can be modified by mounting it as a loop device. This is normally
done prior to writing the image to a SD card.

The following scripts take care of mounting / unmounting the image file.
 - Mounting the image: loop_mount_mnt.sh <filenameOfRaspbianImage>
 - Unmounting the image: loop_mount_umnt.sh <filenameOfRaspbianImage>

Attention:
Both scripts are sym links pointing to loop_mount_main.sh. They get created
by executing any of the scripts or explicitly by executing mod.conf.

Attention
---------
* Please be aware of the fact that the scripts assume that you have got 
  enough space on the partition holding the directories mentioned 
  earlier. This boils down to the downloaded file, the decompressed file 
  and maybe the content of repository holding the scripts.

* The scripts are to be executed by root due to the nature of mounting / 
  writting to devices. Please be aware of this.

* You might want to turn on the "a" flag of the first partition on the 
  target device if you write to a SSD. My Raspberry Pi did not want to
  boot at one point of time as the flag was not set.
* The time I wanted to resize the file system on a SSD I had the problem
  that fdisk showed the new size but df did not. I applied 
  "resize2fs -d 32 /dev/sda2" and the problem was solved.

