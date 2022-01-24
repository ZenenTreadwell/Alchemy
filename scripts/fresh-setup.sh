#!/bin/bash

# Script for installing the base dependencies of AO and getting it running
# Zen, 2022

# Font decoration for better a e s t h e t i c
RED="\e[0;91m"
GREEN="\e[0;92m"
BLUE="\e[0;94m"
BOLD="\e[1m"
ULINE="\e[4m"
RESET="\e[0m"

echo ""
echo -e "${BOLD}Hiya!${RESET} We're going to get you set up with your very own Autonomous Engine."
echo ""
echo -e "This script is designed to ask you just enough questions to keep you involved in the process,\nwhile making it as easy as possible for you to get it going. \n\n${BLUE}press enter to continue${RESET}"
read

echo -e "${ULINE}System Basics${RESET}"

if [ -f "/etc/debian_version" ]; then
	DISTRO="debian"
	echo -e "Debian, Ubuntu, or Raspbian OS detected."
elif [ -f "/etc/arch-release" ]; then
	DISTRO="arch"
	echo -e "Arch- or Manjaro-based OS detected."
elif [ -f "/etc/fedora-release" ]; then
	DISTRO="fedora"
	echo -e "${GREEN}Fedora${RESET} detected as the Operating System"
elif [ $(uname | grep -c "Darwin") -eq 1 ]; then
	DISTRO="mac"
	echo -e "${GREEN}MacOS${RESET} detected."
else
	echo "I don't know what OS you're running! Cancelling this operation."
	exit 1
fi

ARCHY=$(uname -m)

if [ $ARCHY == 'x86_64' ]; then
	echo -e "Ayyy you got yourself an ${GREEN}x86${RESET} processor, cool"
elif [ $ARCHY == 'armv7l' ]; then
	echo -e "I see you rockin an ${GREEN}ARM${RESET} processor, neato"
fi

echo ""

export ALCHEMY_DISTRO=$DISTRO
export ALCHEMY_ARCH=$ARCHY

echo ""

echo -e "Got it! Next we're going to make sure the system's repositories (where they get their data from)\nare updated and that you have all the basic command line utilities we need to continue. \n\n${BLUE}(enter)${RESET}" 
read

install_if_needed() {
    for package in "$@"
    do
        if [ -z $(which $package) ]; then
            echo "installing" $package

            case $DISTRO in
                "debian")
                    sudo apt install -y $package
                    ;;
                "arch")
                    sudo pacman -S $package
                    ;;
                "fedora")
                    sudo dnf install -y $package
                "mac")
                    brew install $package
                    ;;
            esac

        else
            echo $package 'already installed!'
        fi
    done
}

echo "Updating the repositories..."
echo "(you'll probably need to input your 'sudo' password here)"
case $DISTRO in
    "debian")
        sudo apt update
        sudo apt autoremove
        sudo apt upgrade
        ;;
    "arch")
        sudo pacman -Syu
        ;;
    "fedora")
        sudo dnf update
        sudo dnf upgrade
        ;;
    "mac")
        install
        sudo brew update
        ;;
esac
echo ""

echo "Making sure we've got the basics..."
case $DISTRO in
    "debian")
        install_if_needed git wget sqlite3
        ;;
    "arch")
        install_if_needed
        ;;
    "mac")
        install_if_needed
        ;;
    "fedora")
        install_if_needed 
esac
echo ""
# 
# 
# echo 'ao install script to be run within clean Ubuntu 20.04.2.0 64 bit OS'
# echo 'Initializing package updates and upgrades'
# 
# echo ''
# echo 'Execution initialization time'
# date
# echo ''
# 
# sudo apt update -y
# sudo apt upgrade -y
# 
# echo 'Installing apt build stuff'
# sudo apt install -y git wget tor sqlite3 zlib1g-dev libtool-bin autoconf autoconf-archive automake autotools-dev \
# libgmp-dev libsqlite3-dev python python3 python3-mako libsodium-dev build-essential pkg-config libev-dev \
# libcurl4-gnutls-dev libssl-dev fakeroot devscripts
# 
# echo 'Installing node'
# wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
# source ~/.bashrc
# nvm install 16
# source ~/.bashrc
# 
# echo 'Installing bitcoind'
# 
# export ARCHY=$(uname -m)
# if [ $ARCHY == 'x86_64' ]
# then
# wget https://bitcoincore.org/bin/bitcoin-core-22.0/bitcoin-22.0-x86_64-linux-gnu.tar.gz
# tar xf bitcoin-22.0-x86_64-linux-gnu.tar.gz
# fi
# if [ $ARCHY == 'armv7l' ]
# then
# wget https://bitcoincore.org/bin/bitcoin-core-22.0/bitcoin-22.0-arm-linux-gnueabihf.tar.gz
# tar xf bitcoin-22.0-arm-linux-gnueabihf.tar.gz
# fi
# sudo cp bitcoin-22.0/bin/* /usr/local/bin/
# 
# echo 'Installing lightningd'
# git clone https://github.com/ElementsProject/lightning.git lightning
# cd lightning
# git checkout v0.10.2
# ./configure
# sudo make
# sudo make install
# cd ..
# 
# echo 'Installing clboss'
# git clone https://github.com/ZmnSCPxj/clboss.git clboss
# cd clboss
# git checkout 0.11B
# mkdir m4
# autoreconf -i
# ./configure
# make
# sudo make install
# cd ..
# 
# # echo ' '
# # echo 'Installing ao-3'
# # git clone 'https://github.com/AutonomousOrganization/ao-3.git' ao-3
# # cd ao-3
# # npm install
# # npm run build
# # npm run checkconfig
# 
# echo ' '
# echo ' '
# echo '*********************************************************'
# echo 'Version Information'
# echo '*********************************************************'
# 
# echo ' '
# echo 'make Version'
# echo '*********************************************************'
# make --version
# 
# echo ' '
# echo 'node Version'
# echo '*********************************************************'
# node --version
# 
# echo ' '
# echo 'sqlite3 Version'
# echo '*********************************************************'
# sqlite3 --version
# 
# echo ' '
# echo 'tor Version'
# echo '*********************************************************'
# tor --version
# 
# echo ' '
# echo 'bitcoind Version'
# echo '*********************************************************'
# bitcoind --version
# 
# echo ' '
# echo 'lightningd Version'
# echo '*********************************************************'
# lightningd --version
# 
# echo ' '
# echo 'clboss Version'
# echo '*********************************************************'
# clboss --version
# 
# echo ''
# echo 'Execution completion'
# date
# echo ''
# 
# echo 'Lightning Node Installed Start via two terminals: '
# echo '  bitcoind'
# echo '  lightningd'
# echo 'Can Proceed to AO-3 setup: '
# echo '  git clone https://github.com/AutonomousOrganization/ao-3'
# echo '  cd ao-3'
# echo '  npm install'
# echo '  npm run checkconfig'
# echo '  npm build'
# echo '  npm start'
