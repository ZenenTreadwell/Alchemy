#!/usr/bin/env sh

# This is the initialization script for Alchemy. 
# We can't rely on all systems being able to use 'make' etc. by default.
# This will ensure that everything is set up as needed.
# Bare Metal Alchemist, 2022

# Just to let the system know what we're doing...
ALCHEMY="initializing"

# 'sourcing' a script is essentially running it to set up your system,
# making sure that some basic values / variables are defined
source ingredients/lead

clear
echo -e "${BLUE}"
echo -e "       d8888 888          888                                     " 
echo -e "      d88888 888          888                                     " 
echo -e "     d88P888 888          888                                     " 
echo -e "    d88P 888 888  .d8888b 88888b.   .d88b.  88888b.d88b.  888  888" 
echo -e "   d88P  888 888 d88P'    888 '88b d8P  Y8b 888 '888 '88b 888  888" 
echo -e "  d88P   888 888 888      888  888 88888888 888  888  888 888  888" 
echo -e " d8888888888 888 Y88b.    888  888 Y8b.     888  888  888 Y88b 888" 
echo -e "d88P     888 888  'Y8888P 888  888  'Y8888  888  888  888  'Y88888" 
echo -e "                                                               888" 
echo -e "                  ${BOLD}Initialization Script -- BMA${BLUE}            Y8b d88P" 
echo -e "${RESET}"

echo -e "${GREEN}${ULINE}Environment${RESET}"
if [ -f .env ]; then
    grep -v '^#' .env
    export $(grep -v '^#' .env | xargs)
else
    echo "No .env file found, let's initialize it"
    echo "ALCHEMY=true" > .env
fi

echo ""
echo -e "${GREEN}${ULINE}System Basics${RESET}"
if [[ $ISA && $DISTRO && $UPDATED ]]; then
    echo "Nothing to do!"
fi

if [[ ! $ISA ]]; then
    ISA=$(uname -m)
    if [ $ISA == 'x86_64' ]; then
        echo -e "Ayyy you got yourself an ${GREEN}x86${RESET} processor, cool"
    elif [ $ISA == 'armv7l' ]; then
        echo -e "I see you rockin an ${GREEN}ARM${RESET} processor, neato"
    fi
    echo "ISA=$ISA" >> .env
fi

if [[ ! $DISTRO ]]; then
    if [ -f "/etc/debian_version" ]; then
        DISTRO="debian"
        echo -e "${GREEN}Debian${RESET}, Ubuntu, or Raspbian OS detected."
    elif [ -f "/etc/arch-release" ]; then
        DISTRO="arch"
        echo -e "${GREEN}Arch or Manjaro-based${RESET} OS detected."
    elif [ -f "/etc/fedora-release" ]; then
        DISTRO="fedora"
        echo -e "${GREEN}Fedora${RESET} detected as the Operating System"
    elif [ $(uname | grep -c "Darwin") -eq 1 ]; then
        DISTRO="mac"
        echo -e "${GREEN}MacOS${RESET} detected."
    else
        echo -e "I don't know ${RED}what OS you're running${RESET}! Cancelling this operation."
        exit 1
    fi
    echo "DISTRO=$DISTRO" >> .env
fi

# TODO - Update intermittently (like if you haven't run it in a week? use date +%s and (($INT+$INT2))
if [[ ! $UPDATED ]]; then
    echo ""
    echo "Updating the repositories..."
    echo -e "(you'll probably need to input ${BLUE}your 'sudo' password${RESET} here)"
    case $DISTRO in
        "debian")
            sudo apt update
            sudo apt autoremove
            sudo apt upgrade
            sudo apt install build-essential
            ;;
        "arch")
            sudo pacman -Syu --noconfirm
            sudo pacman -S base-devel --noconfirm
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
    echo "UPDATED=true" >> .env
fi

echo ""
echo -e "${GREEN}${ULINE}Core Dependencies${RESET}"
install_if_needed git wget make

echo ""
echo -e "${BOLD}You're good to go!${RESET} Go ${BLUE}make something cool${RESET} :)"
