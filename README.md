This project prepares a downloaded image of Raspbian by applying a 
slight customisation to help with for headless installation onto 
Raspberry Pi.

What is done 
============
* applying a host name
* adding WiFi credentials
* enabling SSH
* further customising by you through a custom script which is executed in case of existance

There are a few scripts handling the entire  process. This gives you 
control of the process if you want to add more info / skip a step etc.

The supplied shell scripts are described in detail in the next section.

Introduction to the shell scripts
=================================

The scripts are thought to be helper scripts for downloading, customising,
and writing an image of the Linux distribution Raspbian to a SD card.


Order of execution
------------------
Here are the actions and the commands plus some explanation on the tasks / results.

1) Downloading: "sudo raspbian_GetLatest.sh <lite|desktop>"
   The latest version of Raspbian will get downloaded to the directory 
   ${IMG_LOCATION} defined in the file mod.conf. The parameter determines
   whether the lite (no GUI) or desktop version will be downloaded.

   The file name will be something like "2018-06-27-raspbian-stretch-lite.zip".
   The URL used for the retrieval is generic and so it will hopefully work
   with the next major release(s) after Raspbian Stretch.

2) Mounting the image: loop_mount_mnt /path/to/my/image/my.img (optional parameter)
   This mounts the latest image file (according to the timestamp in file
   in the directory ${IMG_LOCATION_EDIT}). If an image file name is given
   it will be used instead.

3) Writing customisation to the mounted image: customise_details.sh

4) Unmounting the image: loop_mount_umnt /path/to/my/image/my.img (optional parameter)
   This unmounts the latest image file (according to the timestamp in file
   in the directory ${IMG_LOCATION_EDIT}). If an image file name is given
   it will be used instead

5) Writing the image to the SD card: write_raspbian.sh <image filename> <SD card device>
   This script writes the latest image file to the SD card. The parameters 
   are optional, so either no parameter or two.

   This mounts the latest image file (according to the timestamp in file
   in the directory ${IMG_LOCATION_EDIT}). If an image file name is given
   it will be used instead.


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

