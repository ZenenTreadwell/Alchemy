#!/bin/bash

# Prepares the boot and file system sectors of a Raspberry Pi for on-network use
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

read -p "Which one is your Raspberry Pi USB? type a number, or 'c' to cancel: " -n1 usb
echo ""
echo ""
case $usb in
    c)
        exit
        ;;
    [1-9])
        target=$(sed "${usb}q;d" usb-list | awk '{print $1}')
        echo -e "Targeting ${GREEN}$target${NC} for configuration."
        ;;
    *)
        echo "lol what the heck does $usb mean"
        exit
        ;;
esac
rm usb-list
echo ""

# ------------------- Step 2 - Prepare Boot Sector -------------------

sudo mkdir -p /mnt
sudo mount ${target}1 /mnt
read -p "Do you plan on using this RPi as part of a cluster? (y/n): " -n1 boot
case $boot in
    y | Y)
        echo "Configuring for clustering..."
        sudo bash -c "echo cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory >> /mnt/cmdline.txt"
        ;;
esac
echo ""
echo "Enabling SSH"
sudo touch /mnt/ssh

sudo umount ${target}1
sleep 1

echo "Done with the boot sector."
echo ""


# ------------------- Step 2 - Prepare File System Sector -------------------

sudo mkdir -p /mnt
sudo mount ${target}2 /mnt
read -p "Enter a hostname for this device (leave blank to skip): " hostname
if [[ ! -z $hostname ]]; then
    sudo bash -c "echo ${hostname} > /etc/hostname"
    echo "Hostname configured to $hostname"
fi

read -p "Would you like to copy Alchemy to the new device? (y/n): " -n1 boot
case $boot in
    y | Y)
        echo ""
        echo "zipping and copying..."
        zip -r alchemy ./{Makefile,README.md,resources,scripts}
        sudo cp alchemy.zip /mnt/usr/share/
        echo "done!"
        ;;
esac

sudo umount ${target}2
sleep 1

echo "Done with the file system, you're ready to go!"
echo ""
