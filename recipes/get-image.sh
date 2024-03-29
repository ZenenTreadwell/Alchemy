#!/bin/bash

# Script for automatically downloading and checking the sha256sum of a RPi image

# Font decoration for better a e s t h e t i c
RED="\e[0;91m"
GREEN="\e[0;92m"
BLUE="\e[0;94m"
BOLD="\e[1m"
ULINE="\e[4m"
RESET="\e[0m"

# Links
RASPBIAN_DOWNLOAD_LINK=https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2021-11-08/2021-10-30-raspios-bullseye-arm64-lite.zip
RASPBIAN_IMAGE=2021-10-30-raspios-bullseye-arm64-lite.zip

MANJARO_DOWNLOAD_LINK=https://download.manjaro.org/kde/21.2.1/manjaro-kde-21.2.1-220103-linux515.iso
MANJARO_IMAGE=manjaro-kde-21.2.1-220103-linux515.iso

UBUNTU_DOWNLOAD_LINK=https://releases.ubuntu.com/20.04.3/ubuntu-20.04.3-desktop-amd64.iso
UBUNTU_IMAGE=ubuntu-20.04.3-desktop-amd64.iso
UBUNTU_SHA256SUM="5fdebc435ded46ae99136ca875afc6f05bde217be7dd018e1841924f71db46b5  ubuntu-20.04.3-desktop-amd64.iso"

echo -e "${BOLD}Ah, I see you're looking to download an image!${RESET}"
echo ""
echo -e "${ULINE}Which one?${RESET}"
echo -e "${BOLD}1. ${RESET} Raspbian (arm64 image)"
echo -e "${BOLD}2. ${RESET} Manjaro (x86_64 image)"
echo -e "${BOLD}3. ${RESET} Ubuntu (x86_64 image)"
echo ""

IMAGE=
while [ -z $IMAGE ]; do
    read -p "enter a number (c to cancel): " -n1 img
    echo ''
    case $img in
        'c')
            exit 1
            ;;
        1)
            echo "Raspbian selected!"
            DOWNLOAD_LINK=$RASPBIAN_DOWNLOAD_LINK
            IMAGE=$RASPBIAN_IMAGE
            ;;
        2)
            echo "Manjaro selected!"
            DOWNLOAD_LINK=$MANJARO_DOWNLOAD_LINK
            IMAGE=$MANJARO_IMAGE
            ;;
        3)
            echo "Ubuntu selected!"
            DOWNLOAD_LINK=$UBUNTU_DOWNLOAD_LINK
            IMAGE=$UBUNTU_IMAGE
            SHA256SUM=$UBUNTU_SHA256SUM
            ;;
        *)
            echo "wait that doesn't make sense, try again"
            ;;
    esac
done

mkdir -p images

if [[ -e images/$IMAGE ]]; then
    echo "Image has already been downloaded."
else
    echo "Downloading $IMAGE to images/ folder"
    curl -o images/$IMAGE $DOWNLOAD_LINK
fi

cd images
if [[ -z $SHA256SUM ]]; then
    echo "Getting sha256sum and comparing..."
    curl -so image.sha256 $DOWNLOAD_LINK.sha256
else
    echo "${SHA256SUM}" > image.sha256
fi

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
