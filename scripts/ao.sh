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

clear
echo ''
echo '       d8888  .d88888b.       8888888                   888             888 888                  '
echo '      d88888 d88P" "Y88b        888                     888             888 888                  '
echo '     d88P888 888     888        888                     888             888 888                  '
echo '    d88P 888 888     888        888   88888b.  .d8888b  888888  8888b.  888 888  .d88b.  888d888 '
echo '   d88P  888 888     888        888   888 "88b 88K      888        "88b 888 888 d8P  Y8b 888P"   '
echo '  d88P   888 888     888        888   888  888 "Y8888b. 888    .d888888 888 888 88888888 888     '
echo ' d8888888888 Y88b. .d88P        888   888  888      X88 Y88b.  888  888 888 888 Y8b.     888     '
echo 'd88P     888  "Y88888P"       8888888 888  888  88888P"  "Y888 "Y888888 888 888  "Y8888  888     '
echo ''
                                                                                                 

# ------------------- Step 1 - Baseline Setup -------------------

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
                    ;;
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
echo -e "(you'll probably need to input ${BLUE}your 'sudo' password${RESET} here)"
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
        # sudo dnf update
        # sudo dnf upgrade
        ;;
    "mac")
        install
        sudo brew update
        ;;
esac
echo ""

echo -e "Making sure we've got the basics..."
case $DISTRO in
    "debian")
        # Note -- I'm not sure if these are all needed but I'm not in the mood to check
        install_if_needed git wget tor sqlite3 zlib1g-dev libtool-bin autoconf autoconf-archive automake autotools-dev \
        libgmp-dev libsqlite3-dev python python3 python3-mako libsodium-dev build-essential pkg-config libev-dev \
        libcurl4-gnutls-dev libssl-dev fakeroot devscripts
        ;;
    "arch")
        # install_if_needed 
        ;;
    "mac")
        # install_if_needed
        ;;
    "fedora")
        # install_if_needed git wget tor sqlite3 autoconf autoconf-archive automake \
        # python python3 python3-mako pkg-config fakeroot devscripts
        ;;
esac
echo ""

# ------------------- Step 2 - AO Environment Setup -------------------

AO=''
echo -e "Hey! You still there? I was wondering which ${BLUE}version of AO${RESET} you wanted to install. \n"
echo -e "${BOLD}1.${RESET} ao-3 (Vue)"
echo -e "${BOLD}2.${RESET} ao-react (React)"
while [[ -z $AO ]]; do
    echo -en "${BLUE}(number):${RESET} "
    read -n1 ao_select 
    echo ""
    echo ""

    case $ao_select in
        "1")
            echo "Minimalism, I like it! Proceeding with ao-3 installation"
            AO=vue
            ;;
        "2")
            echo "The DCTRL special! Proceeding with ao-react installation"
            AO=react
            ;;
        *)
            echo "that aint no AO i ever heard of, try again"
            ;;
    esac
done;
echo ""

if [ $AO = "vue" ] || [ $AO = 'react' ]; then
    echo -e "${BOLD}Installing Node.js${RESET}"
    chmod +x scripts/nvm_install.sh
    scripts/nvm_install.sh
    source ~/.bashrc
    nvm install v16.13.0
    nvm alias default v16.13.0
    source ~/.bashrc
    echo ""
fi

if [ $AO = "vue" ] || [ $AO = 'react' ]; then
    echo -e "${BOLD}Installing Bitcoin Ecosystem${RESET}"
    mkdir -p bitcoin

    if [ $ALCHEMY_ARCH == 'x86_64' ] && [ ! -e images/bitcoin-22.0* ]; then
        wget https://bitcoincore.org/bin/bitcoin-core-22.0/bitcoin-22.0-x86_64-linux-gnu.tar.gz -P images/
    elif [ $ALCHEMY_ARCH == 'armv7l' ] && [ ! -e images/bitcoin-22.0* ]; then
        wget https://bitcoincore.org/bin/bitcoin-core-22.0/bitcoin-22.0-arm-linux-gnueabihf.tar.gz -P images/
    fi

    tar -xvf images/bitcoin-22.0*.tar.gz

    sudo cp bitcoin-22.0/bin/* /usr/local/bin/

    #echo 'Installing lightningd'
    #git clone https://github.com/ElementsProject/lightning.git lightning
    #cd lightning
    #git checkout v0.10.2
    #./configure
    #sudo make
    #sudo make install
    #cd ..

    #echo 'Installing clboss'
    #git clone https://github.com/ZmnSCPxj/clboss.git clboss
    #cd clboss
    #git checkout 0.11B
    #mkdir m4
    #autoreconf -i
    #./configure
    #make
    #sudo make install
    #cd ..

    echo -e "${BOLD}Bitcoin installed!${RESET} Let's make sure it's configured now."
fi
echo ''

if [ $AO = "vue" ] || [ $AO = 'react' ]; then
    echo "We still need to install and configure Tor..."
fi

# ------------------- Step 3 - AO Installation -------------------

case $AO in
    "vue")
        echo 'Installing ao-3'
        git clone 'https://github.com/AutonomousOrganization/ao-3.git' ~/ao-3
        pushd ~/ao-3
        npm install
        npm run build
        npm run checkconfig
        popd
        ;;
    "react")
        echo "soon it will be done"
        ;;
esac

# ------------------- Step 4 - Systemd Setup -------------------


# ------------------- Step 5 - Health Check -------------------

# echo ''
# echo ''
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
