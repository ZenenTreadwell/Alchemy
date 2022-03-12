#!/bin/sh

# Script for installing the base dependencies of AO and getting it running
# Bare Metal Alchemist, 2022

source ingredients/lead
source ingredients/copper
source ingredients/iron
source ingredients/gold

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
echo -e "This script is designed to ask you just enough questions to keep you involved in the process,"
echo -e "while making it as easy as possible for you to get it going." 
echo ""
echo -e "${BLUE}press enter to continue${RESET}"
read

if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}Woah there!${RESET} Seems you're running this script as a superuser."
    echo ""
    echo "That might cause some issues with permissions and whatnot. Run this script as your default user (without sudo) and I'll ask you when I need superuser permissions"
    echo ""
    exit 1
fi

echo -e "Making sure we've got the basics..."
echo -e "(you'll probably need to input ${BLUE}your 'sudo' password${RESET} here)"
case $DISTRO in
    "debian")
        # Note -- I'm not sure if these are all needed but I'm not in the mood to check
        install_if_needed git wget sqlite3 zlib1g-dev libtool-bin autoconf autoconf-archive automake autotools-dev \
        libgmp-dev libsqlite3-dev python python3 python3-mako libsodium-dev build-essential pkg-config libev-dev \
        libcurl4-gnutls-dev libssl-dev fakeroot devscripts
        ;;
    "arch")
        if [[ ! $(pacman -Qg base-devel) ]]; then
            sudo pacman -S base-devel --noconfirm
        fi

        install_if_needed wget python gmp sqlite3 autoconf-archive pkgconf libev \
            python-mako python-pip net-tools zlib libsodium gettext nginx
        ;;
    "mac")
        # install_if_needed better-computer
        ;;
    "fedora")
        install_if_needed git wget tor sqlite3 autoconf autoconf-archive automake \
        python python3 python3-mako pkg-config fakeroot devscripts
        ;;
esac
echo ""

# ------------------- Step 2 - AO Environment Setup -------------------

if [ ! -z $AO ]; then
    echo "You're currently using ao-$AO"
    echo -en "Would you like to re-install? ${BLUE}(y/n): ${RESET}"
    read reinstall_ao
    echo ""
    case $reinstall_ao in
        "Y" | "y")
            forget AO
            ;;
        *)
            echo "Okay, we'll keep using this version of AO"
            ;;
    esac
fi

if [ -z $AO ]; then
    AO=''
    echo -e "${BOLD}Hey!${RESET} I was wondering which ${BLUE}version of AO${RESET} you wanted to install. \n"
    echo -e "${BOLD}1.${RESET} ao-3 (Vue)"
    echo -e "${BOLD}2.${RESET} ao-react (React)"
fi

while [[ -z $AO ]]; do
    echo -en "${BLUE}(number):${RESET} "
    read -n1 ao_select
    echo ""
    echo ""

    case $ao_select in
        "1")
            echo -e "Minimalism, I like it! Proceeding with ${BLUE}ao-3${RESET} installation"
            AO='3'
            ;;
        "2")
            echo -e "It's got community! Proceeding with ${BLUE}ao-react${RESET} installation"
            AO='react'
            ;;
        *)
            echo "that aint no AO i ever heard of, try again"
            ;;
    esac
done;
remember "AO=${AO}"

echo ""
if [ $AO = "3" ] || [ $AO = 'react' ]; then
    if [ -z $NVM_DIR ]; then
        install_nvm
        source ingredients/iron
    else
        echo -e "${BLUE}Node${RESET} already installed!"
    fi

    echo -e "Setting Node to ${BLUE}v16.13.0${RESET} for compatibility"
    set_node_to v16.13.0
    echo ""
    echo -e "${GREEN}Done!${RESET}"
    echo ""
fi

if [ $AO = "3" ] || [ $AO = 'react' ]; then
    echo -e "${BOLD}Installing Bitcoin Ecosystem${RESET}"
    echo ""

    if ! check_for bitcoind; then
        echo -e "Building bitcoind from source... might take a while!"
        install_bitcoin
    fi

    if ! check_for lightningd; then
        echo -e "Building lightningd from source... here we go again"
        install_lightning
    fi

    configure_bitcoin
    configure_lightning
fi
echo ''

if [ $AO = "3" ] || [ $AO = 'react' ]; then
    echo -e "${BOLD}Installing and configuring Tor${RESET}\n"
    install_if_needed tor
    configure_tor
    echo ""
fi

# ------------------- Step 3 - AO Installation -------------------

echo -e "${BOLD}Configuring AO Core${RESET}\n"

mkdir -p $HOME/.ao

if  [ -f $HOME/.ao/key ]; then
    echo 'We already have a private key for this AO, sweet!'
else
    node scripts/createPrivateKey.js >> $HOME/.ao/key
    echo -e "Just made a fresh private key and put it in ${GREEN}~/.ao${RESET}"
fi
echo ""

# TODO this is really janky/fragile, it would be better to store this in ~/.ao
CONFIG_FILE=$HOME/ao-$AO/configuration.js
UNIFIED_CONFIG=$HOME/.ao/env
if [ ! -f "$UNIFIED_CONFIG" ]; then
    touch $UNIFIED_CONFIG
fi

remember "SQLITE_DATABASE=${HOME}/.ao/database.sqlite3" to "$UNIFIED_CONFIG"
remember "PASSLINE=${BTC_PASS}" to "$UNIFIED_CONFIG"
remember "PRIVATEKEY=${HOME}/.ao/key" to "$UNIFIED_CONFIG"
remember "CLIGHTNING_DIR=${HOME}/.lightning/bitcoin" to "$UNIFIED_CONFIG"
remember "MEMES_DIR=${HOME}/.ao/memes" to "$UNIFIED_CONFIG"
remember "RENT=0" to "$UNIFIED_CONFIG"
remember "LIGHTNINGDIR=0" to "$UNIFIED_CONFIG"

say "!!!!!!! WARNING !!!!!! I'm exaggerating but this is not going to \
configure AO properly. It's time that we build out the unified config"
read
case $AO in
    "3")
        if [ ! -d ~/ao-3 ]; then
            echo -e "Installing ${BLUE}ao-3${RESET}"
            git clone 'https://github.com/AutonomousOrganization/ao-3.git' ~/ao-3
        fi
        if [ -f "$CONFIG_FILE" ]; then
            echo configuration.js already exists
        else
            cp resources/ao-config $CONFIG_FILE
            sed -i "s#SQLITE_DATABASE#${HOME}/.ao/database.sqlite3#" $CONFIG_FILE
            sed -i "s#PASSLINE#${BTC_PASS}#" $CONFIG_FILE
            sed -i "s#PRIVATEKEY#${HOME}/.ao/key#" $CONFIG_FILE
            sed -i "s#CLIGHTNING_DIR#${HOME}/.lightning/bitcoin#" $CONFIG_FILE
            sed -i "s#MEMES_DIR#${HOME}/.ao/memes#" $CONFIG_FILE
        fi

        echo ""
        pushd ~/ao-3
        npm install
        npm run build
        npm run checkconfig
        popd

        NODE_PARAMS=''
        ;;
    "react")
        echo -e "Installing ${BLUE}ao-react${RESET}"
        if [ ! -d ~/ao-react ]; then
            git clone 'https://github.com/coalition-of-invisible-colleges/ao-react.git' ~/ao-react
        fi
        if [ -f "$CONFIG_FILE" ]; then
            echo configuration.js already exists
        else
            cp resources/ao-config $CONFIG_FILE
            sed -i "s#SQLITE_DATABASE#${HOME}/.ao/database.sqlite3#" $CONFIG_FILE
            sed -i "s#PASSLINE#${BTC_PASS}#" $CONFIG_FILE
            sed -i "s#PRIVATEKEY#${HOME}/.ao/key#" $CONFIG_FILE
            sed -i "s#CLIGHTNING_DIR#${HOME}/.lightning/bitcoin#" $CONFIG_FILE
            sed -i "s#MEMES_DIR#${HOME}/.ao/memes#" $CONFIG_FILE
        fi

        echo ""

        pushd ~/ao-react
        npm install
        npm run webpack
        popd
        
        NODE_PARAMS='--experimental-specifier-resolution=node -r dotenv/config'
        ;;
esac

# ------------------- Step 4 - NGINX Setup -------------------

 echo ""
 echo -en "You still there? I might need your input here! \n\n${BLUE}(enter)${RESET}"
 read

 initialize_nginx
 make_site ao "FILE_ROOT=${HOME}/ao-${AO}/dist"
 echo ""
 configure_domain_for_site ao
 enable_ssl

 echo -e "Excellent! We've configured this computer to serve your AO from ${BLUE}${ACCESS_POINT}${RESET}"

# ------------------- Step 7 - Systemd Setup -------------------

READY=''
echo -e "\n${BOLD}Alright, almost there!${RESET} Now we just need to set up the system daemons for Tor, Bitcoin, Lightning, and the AO so that everything opens on startup."
while [[ -z $READY ]]; do
    echo -en "${BLUE}You ready? (y/n):${RESET} "
    read -n1 ao_select
    echo ""
    echo ""

    case $ao_select in
        "y" | "Y")
            echo -e "Nice, let's do it.\n"
            READY=1
            ;;
        *)
            echo -e "wrong answer, fren\n"
            ;;
    esac
done

build_service_from_template tor "TORRCPATH=$TORRCPATH" "TORPATH=`which tor`"

# Creating the .tor directory
sudo mkdir -p $HOME/.tor
sudo chown tor $HOME/.tor
sudo chgrp $USER $HOME/.tor
sudo chmod 770 $HOME/.tor

activate_service tor

echo ""
build_service_from_template bitcoin "BITCOIND=`which bitcoind`"
activate_service bitcoin

echo ""
build_service_from_template lightning "LIGHTNINGD=`which lightningd`"
activate_service lightning

echo ""
build_service_from_template ao "NODE=`which node`" "AO=$AO" "NODE_PARAMS=$NODE_PARAMS"
activate_service ao

echo "this should be nginx"
activate_service nginx

# ------------------- Step 8 - Port Testing -------------------

echo ""
echo -e "${BOLD}One more thing!${RESET} We need to make sure that your ports are open."
echo ""
check_ports

# ------------------- Step 9 - Health Check -------------------

 echo '*********************************************************'
 echo -e "*                  ${BOLD}Version Information${RESET}                  *"
 echo '*********************************************************'

 echo ' '
 echo 'make Version'
 echo '*********************************************************'
 make --version

 echo ' '
 echo 'node Version'
 echo '*********************************************************'
 node --version

 echo ' '
 echo 'sqlite3 Version'
 echo '*********************************************************'
 sqlite3 --version

 echo ' '
 echo 'tor Version'
 echo '*********************************************************'
 tor --version

 echo ' '
 echo 'bitcoind Version'
 echo '*********************************************************'
 bitcoind --version

 echo ' '
 echo 'lightningd Version'
 echo '*********************************************************'
 lightningd --version

 echo ' '
 echo 'clboss Version'
 echo '*********************************************************'
 clboss --version
echo ""
echo -e "$BOLD\nOkay, well that's everything!${RESET}\n\nAs long as everything worked properly, \
you should be ready to continue your journey\ntowards autonomy by opening ${BLUE}$ACCESS_POINT${RESET} in your browser."
echo -e "The default login is ${BLUE}dctrl/dctrl${RESET}, have fun!"

exit 0
