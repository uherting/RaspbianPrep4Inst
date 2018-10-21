This project was born out of a need to have a standard process to prepare the headless installation onto a Raspberry Pi. With the help of the scripts from this project an image of Raspbian can be downloaded, customised and written to a storage card. as I (and maybe you, too) like to control the process I separated the functionality into several scripts with a common configuration file. 

Most of Raspberry Pies I own are of the type Zero W and as I run them headlessly I used the lite version of Raspbian in the beginning for this project, but the same steps described here can be used to prepare a desktop image file.
 
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
  There is the 
* Do I want to log to RAM? If the file Templates/log2ram.mk exists the snapshot of 
  log2ram (for details see https://github.com/azlux/log2ram) is installed. 

  If you create the file in the boot partition on the storage card after 
  the Raspberry Pi booted the log2ram application is installed from the 
  directory /log2ram in the root partition at the next booting of the 
  Raspberry Pi.
* Shall the entire storage card be used? It might be nice to have a small 
  footprint for testing some things. As soon as the file Templates/noresize 
  exists, the resizing will not occur as part of the booting of the Raspberry Pi.

  If you delete the file in the boot partition on the storage card after 
  the Raspberry Pi booted the resize process will be executed on the next boot.

  Please pay attention to the fact that the process of resizing the file 
  system cannot be reversed.
* Is the Raspberry Pi connected to the Router via WiFI_ In case you want to 
  edit the file Templates/wpa_supplicant.conf to suit your needs (country, 
  SSID and PSK).

The files described above are created in the boot partition of the image by 
means are written later onto the storage card. 

Introduction to the shell scripts
=================================

The scripts are thought to be helper scripts for downloading, customising,
and writing an image of the Linux distribution Raspbian to a SD card.
Additional Customisation can be done through a script you supply, see 
section "Additional Customisation" for details.

Order of execution
------------------
Here are the actions and the commands plus some explanation on the tasks / results.

1) Downloading: "sudo raspbian_GetLatest.sh <lite|desktop>"
   The latest version of Raspbian will get downloaded to the directory 
   ${IMG_LOCATION_DOWNLOAD} defined in the file mod.conf. The parameter 
   determines whether the lite (no GUI) or desktop version will be downloaded.

   The file name will be something like "2018-06-27-raspbian-stretch-lite.zip".
   The URL used for the retrieval is generic and so it will hopefully work
   with the next major release(s) after Raspbian Stretch.

   The downloaded file will be decompressed. After being decompressed it 
   will be moved to the ${IMG_LOCATION_DOWNLOAD_ARCHIVE} directory while 
   the extracted file goes into the ${IMG_LOCATION_EDIT} directory.

2) Mounting the image: loop_mount_mnt /path/to/my/image/my.img (optional parameter)
   This mounts the latest image file (according to the timestamp in file
   in the directory ${IMG_LOCATION_EDIT}). If an image file name is given
   it will be used instead.
   
   The partitions contained in the image file can be found in the directory 
   ${IMG_LOCATION_MOUNT}/* .

3) Writing customisation to the mounted image: customise_details.sh <hostname> <wifi|nowifi>
   This script is the heart of the project. It modifies some files 
   contained in the image file and adds a few more. 

   The parameter <hostname> is used to change the original initial 
   hostname from "raspberrypi" to the given string.

   The parameter <wifi|nowifi> is used to determine whether the file 
   wpa_supplicant.conf containing the WiFi credentials is transferred 
   to the boot partition.

4) Unmounting the image: loop_mount_umnt /path/to/my/image/my.img (optional parameter)
   This unmounts the latest image file (according to the timestamp in file
   in the directory ${IMG_LOCATION_EDIT}). If an image file name is given
   it will be used instead.

5) Writing the image to the SD card: write_raspbian.sh <image filename> <SD card device>
   This script writes the an image file to the SD card. The parameters 
   are optional.

   This mounts the latest image file (according to the timestamp in file
   in the directory ${IMG_LOCATION_EDIT}) or the image file given on 
   command line.

   If you want to supply the <SD card device> then you have to supply the <image filename>, too.


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
Please be aware of the fact that the scripts assume that you have got enough space on the partition holding the directories mentioned earlier. This boils down to the downloaded file, the decompressed file and maybe the content of repository holding the scripts.

