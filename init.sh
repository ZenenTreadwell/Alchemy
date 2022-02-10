#!/usr/bin/env bash

# This is the initialization script for Alchemy. We can't rely on all systems being able to use 'make' or other utilities by default.
# This will ensure that everything is set up as needed.
# Bare Metal Alchemist, 2022

# This runs the ingredients script as part of this one,
# making sure that some basic values / variables are defined
source scripts/ingredients

echo ""
echo -e "${GREEN}${ULINE}Environment${RESET}"
if [ -f .env ]; then
    grep -v '^#' .env
    export $(grep -v '^#' .env | xargs)
else 
    echo "No .env file found, initializing"
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

if [[ ! $UPDATED ]]; then
    echo ""
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
echo -e "${GREEN}${ULINE}Base Dependencies${RESET}"                                                                                                                                                                                           
install_if_needed make git wget
