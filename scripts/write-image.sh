#!/bin/bash

# Script for writing a supplied image file to a data storage device (just usb drives for now)
# Zen, 2022

# Font decoration for better a e s t h e t i c
RED="\e[0;91m"
GREEN="\e[0;92m"
BLUE="\e[0;94m"
BOLD="\e[1m"
ULINE="\e[4m"
NC="\e[0m"

# ------------------- Step 1 - Select USB -------------------

echo "Looking for USB devices..."
echo ""
echo -e "${ULINE}Found these!${NC}"
lsblk -pdo NAME,MODEL,TRAN | grep usb > usb-list
i=1
while read -u 11 line; do
    echo -e "${BOLD}$i.${NC} $line"
    i=$((i+1))
done 11<usb-list
echo ""

read -p "Which USB would you like to write to? type a number, or 'c' to cancel: " -n1 dev
echo ""
echo ""
case $dev in
    c)
        exit
        ;;
    [1-9])
        target=$(sed "${dev}q;d" usb-list | awk '{print $1}')
        echo -e "Writing image to: ${GREEN}$target${NC}"
        ;;
    *)
        echo "lol what the heck does $dev mean"
        exit
        ;;
esac

# ------------------- Step 2 - Select Image -------------------

ls images > img-list
i=1
echo ""
echo -e "${ULINE}Images${NC}"
while read -u 11 line; do
    echo -e "${BOLD}$i.${NC} $line"
    i=$((i+1))
done 11<img-list
echo ""
read -p "Which image do you want to use? type a number, or 'c' to cancel: " -n1 img
echo ""
echo ""
case $img in
    c)
        exit
        ;;
    [1-9])
        image=$(sed "${img}q;d" img-list | awk '{print $1}')
        echo -e "Okay, we're using ${BLUE}$image${NC} as the image file."
        ;;
    *)
        echo "lol what the heck does $img mean"
        exit
        ;;
esac

# ------------------- Step 3 - Write Image to USB -------------------

echo ""
echo -e "Getting ready to write ${GREEN}$image${NC} to ${BLUE}$target${NC}"
echo ""
read -p "Press Enter to continue (ctrl+C to cancel):" 

case $image in
    *.iso)
        sudo dd if=images/$image of=$target bs=4M conv=fsync status=progress
        ;;
    *.zip)
        unzip -p "images/$image" | sudo dd of=$target bs=4M conv=fsync status=progress
        ;;
    *)
        echo "I don't know what to do with this file extension, sorry!"
        exit
        ;;
esac

# Leaving this line in if I want to debug and not necessarily run dd all the time
# echo "unzip -p \"images/$image\" | sudo dd of=$target bs=4M conv=fsync status=progress"


# ------------------- Step 4 - Cleaning Up -------------------

rm usb-list
rm img-list
echo ""
echo -e "${BOLD}Congratulations!${NC} Write operation complete."
echo "You probably want to prepare the USB with 'make preparations' before you use it."
