#!/bin/bash

# Script for automatically downloading and checking the sha256sum of a RPi image

# Variables
DOWNLOAD_LINK=https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2021-11-08/2021-10-30-raspios-bullseye-arm64-lite.zip
IMAGE=2021-10-30-raspios-bullseye-arm64-lite.zip

mkdir -p images

if [[ -e images/$IMAGE ]]; then
    echo "Image has already been downloaded."
else
    echo "Downloading Raspberry Pi OS for arm64 architecture"
    curl -o images/$IMAGE $DOWNLOAD_LINK
fi

echo "Getting sha256sum and comparing..."
cd images
curl -so image.sha256 $DOWNLOAD_LINK.sha256
sha256sum $IMAGE > computed.sha256
diff image.sha256 computed.sha256

if [[ $? -eq 0 ]]; then
    echo "Image is healthy!"
else
    echo "Bad sha256sum :( deleting image"
    rm ../images/$IMAGE
fi

rm *.sha256
cd ..

#ifeq ($(WRITABLE_BLOCK),) 
## NOTE: This is not fully functional yet, not sure why
#@read -p "Remove your flash drive, and press enter to continue"
#@lsblk -pdo NAME,TRAN > current-blocks
#@read -p "Insert your writeable drive, and press enter to continue"
#@lsblk -pdo NAME,TRAN | diff current-blocks - | grep usb | awk '{print $$2}' > block.txt
#@export BLOCK=`cat block.txt`
#$(error No USB detected, wait a moment after plugging in and try again)
#else
#    @read -p "the memory block to be modified is $(WRITABLE_BLOCK), ensure this is the drive you wish to write to and press enter to continue"
#    @unzip -p $(IMAGE) | sudo dd of=$(WRITABLE_BLOCK) bs=4M conv=fsync status=progress
#    @rm block.txt current-blocks
#    endif

