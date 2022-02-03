#!/bin/bash

# Script for installing the base dependencies of AO and getting it running
# Zen, 2022

# Font decoration for better a e s t h e t i c
RED="\e[0;31m"
GREEN="\e[0;32m"
BLUE="\e[0;34m"
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

# This is a bash function!
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
    if [ "$SHELL" = '/bin/zsh' ]; then
        echo 'sourcing zshrc'
        source ~/.zshrc
    else
        source ~/.bashrc
    fi
    nvm install v16.13.0
    nvm alias default v16.13.0
    if [ "$SHELL" = '/bin/zsh' ]; then
        echo 'sourcing zshrc'
        source ~/.zshrc
    else
        source ~/.bashrc
    fi
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
    if  [ -f $HOME/.bitcoin/bitcoin.conf ]; then                                                                                                                                                                                      
        echo 'bitcoin config exists'                                                                                                                                                                                                    
    else                                                                                                                                                                                                                              
        cp resources/sample_bitcoin.conf $HOME/.bitcoin/bitcoin.conf                                                                                                                                                                          
        echo 'created default bitcoin config'                                                                                                                                                                                          
    fi                                                                                                                                                                                                                                

    if  [ -f $HOME/.lightning/config ]; then                                                                                                                                                                                         
        echo 'lightning config exists'                                                                                                                                                                                                
    else                                                                                                                                                                                                                              
        cp resources/sample_lightning_config $HOME/.lightning/config                                                                                                                                                                          
        echo 'created default lightning config'                                                                                                                                                                                        
    fi                                                                                                                                                                                                                                
                                                                                                                                                                                                                                      
    AUTHDEETS=$(python3 ./rpcauth.py ao)                                                                                                                                                                                              
    AUTHLINE=$(echo $AUTHDEETS | grep -o rpcauth=ao:[^[:space:]]*[[:space:]])                                                                                                                                                         
    PASSLINE=$(echo $AUTHDEETS | grep -o [^[:space:]]*\$)                                                                                                                                                                             
    echo $AUTHLINE >> $HOME/.bitcoin/bitcoin.conf  
fi
echo ''

if [ $AO = "vue" ] || [ $AO = 'react' ]; then
    echo -e "${BOLD}Installing and configuring Tor${RESET}\n"
    install_if_needed tor

    TORRCPATH='/usr/local/etc/tor/torrc'
    if [ ! -d "/usr/local/etc/tor" ];
    then
        sudo mkdir -p /usr/local/etc/tor
    fi

    if [ ! -f $TORRCPATH ];
    then
        sudo echo "ControlPort 9051" >> $TORRCPATH
        sudo echo "CookieAuthentication 1" >> $TORRCPATH
        sudo chmod 666 $TORRCPATH # so controlport can modify . . . is this bad?
    fi

    if [ $(cat $TORRCPATH | grep -c "HiddenServiceDir /var/lib/tor/ao") -eq 0 ];
    then
        echo "HiddenServiceDir /var/lib/tor/ao" | sudo tee -a $TORRCPATH 1>/dev/null 2>&1
    fi

    if [ $(cat $TORRCPATH | grep -c "HiddenServicePort 80 127\.0\.0\.1:8003") -eq 0 ];
    then
        echo "HiddenServicePort 80 127.0.0.1:8003" | sudo tee -a $TORRCPATH 1>/dev/null 2>&1
    fi

    if [ ! -d "/var/lib/tor" ];
    then
        sudo mkdir -p /var/lib/tor
    fi

    if [ ! -d "/var/lib/tor/ao" ];
    then
        sudo mkdir -p /var/lib/tor/ao
    fi

    sudo chown -R $USER:$USER /var/lib/tor
    sudo chmod -R 700 /var/lib/tor
fi

# ------------------- Step 3 - AO Installation -------------------

echo -e "${BOLD}Configuring AO Core${RESET}\n"

if [ -d $HOME/.ao ]; then                                                                                                                                                                                                        
    echo 'default AO dir exists'                                                                                                                                                                                                
else                                                                                                                                                                                                                              
    mkdir $HOME/.ao                                                                                                                                                                                                               
fi                                                                                                                                                                                                                                

if  [ -f $HOME/.ao/key ]; then                                                                                                                                                                                                   
    echo 'ao privkey exists'                                                                                                                                                                                                      
else                                                                                                                                                                                                                              
    node ./createPrivateKey.js >> $HOME/.ao/key                                                                                                                                                                           
    echo 'created ao privkey'                                                                                                                                                                                                     
fi    

echo ""
case $AO in
    "vue")
        echo -e "Installing ${BLUE}ao-3${RESET}"
        git clone 'https://github.com/AutonomousOrganization/ao-3.git' ~/ao-3
        pushd ~/ao-3
        npm install
        npm run build

        if [ -f "$HOME/ao-3/configuration.js" ]; then                                                                                                                                                                             
            echo configuration.js already exists                                                                                                                                                                                      
        else                                                                                                                                                                                                                          
            cp resources/ao-config $HOME/ao-react/configuration.js
            sed -i "s#SQLITE_DATABASE#${HOME}/.ao/database.sqlite3#" $HOME/ao-react/configuration.js
            sed -i "s#CLIGHTNING_DIR#${HOME}/.lightning/bitcoin#" $HOME/ao-react/configuration.js
            sed -i "s#MEMES_DIR#${HOME}/.ao/memes#" $HOME/ao-react/configuration.js
        fi                                                                                                                                                                                                                            

        npm run checkconfig
        popd
        ;;
    "react")
        echo -e "Installing ${BLUE}ao-react${RESET}"
        git clone 'https://github.com/coalition-of-invisible-colleges/ao-react.git' ~/ao-react

        if [ -f "$HOME/ao-react/configuration.js" ]; then                                                                                                                                                                             
            echo configuration.js already exists                                                                                                                                                                                      
        else                                                                                                                                                                                                                          
            cp resources/ao-config $HOME/ao-react/configuration.js
            sed -i "s#SQLITE_DATABASE#${HOME}/.ao/database.sqlite3#" $HOME/ao-react/configuration.js
            sed -i "s#CLIGHTNING_DIR#${HOME}/.lightning/bitcoin#" $HOME/ao-react/configuration.js
            sed -i "s#MEMES_DIR#${HOME}/.ao/memes#" $HOME/ao-react/configuration.js
        fi                                                                                                                                                                                                                            
                
        pushd ~/ao-react
        npm install
        npm run webpack
        popd
        ;;
esac

# ------------------- Step 4 - NGINX Setup -------------------

echo ""
echo "We might need to query DNS records here..."
install_if_needed dig
echo -e "You still there? I need to ask you some questions! \n\n${BLUE}(enter)${RESET}" 
read
echo ""
read -p "Do you have a domain name pointing to this computer? (y/n): " dns
echo ""
case $dns in
    y | Y)
        echo "Good to hear! What is it?"
        read -p "http://" domain
        ;;
    *)
        echo "Okay, let's just leave it open for now."
        domain=$(dig @resolver4.opendns.com myip.opendns.com +short)
        anywhere=1
        echo "Try accessing this AO from either localhost, 127.0.0.1, or ${domain}"
        ;;
esac
echo ""
AO_NGINX_CONF=/etc/nginx/sites-available/ao
sudo cp resources/ao.nginx.conf $AO_NGINX_CONF

if [ -n $anywhere ]; then
    sudo sed -i "s#SERVER_NAME#_#" $AO_NGINX_CONF
else
    sudo sed -i "s#SERVER_NAME#${domain}#" $AO_NGINX_CONF
fi

sudo sed -i "s#FILE_ROOT#${HOME}/ao-react/dist#" $AO_NGINX_CONF
sudo ln -s /etc/nginx/sites-available/ao /etc/nginx/sites-enabled/
echo ""
sudo systemctl reload nginx
echo "Excellent! We've configured $AO_NGINX_CONF to serve your AO from $domain"
echo ""

read -p "Would you like to enable SSL via Certbot? (y/n): " -n1 ssl
echo ""
case $ssl in
    y | Y)
	echo "Alright, let's get Certbot in here!"
	install_if_needed python3 certbot python3-certbot-nginx
	echo -e "${BOLD}Take it away, Certbot${NC}"
	sudo certbot --nginx
        ;;
    *)
	echo "Yea, SSL is lame anyways..."
	;;
esac
echo ""

# ------------------- Step 7 - Systemd Setup -------------------

READY=''
echo -e "Alright, almost there! Now we just need to set up the system daemons for Tor, Bitcoin, Lightning, and the AO so that everything opens on startup."
while [[ -z $AO ]]; do
    echo -en "${BLUE}You ready? (y/n):${RESET} "
    read -n1 ao_select 
    echo ""
    echo ""

    case $ao_select in
        "y" | "Y")
            echo "Nice, let's do it.\n"
            READY=1
            ;;
        *)
            echo "wrong answer, fren\n\n"
            ;;
    esac
done

echo "Creating tor.service..."
TOR_SERVICE=/etc/systemd/system/tor.service
if [ -f "$TOR_SERVICE" ]; then
    echo "Seems like you've already got tor here!"
else
    sudo cp resources/tor-service-template $TOR_SERVICE
    sudo sed -i "s#USER#${USER}#g" $TOR_SERVICE
fi


# ------------------- Step 8 - Health Check -------------------
# ------------------- Step 9 - Port Testing -------------------

echo -e "${BOLD}One more thing!${NC} We need to make sure that your ports are open."
nmap -Pn $domain > nmap.txt
OPEN=1
if grep -qE "^80/.*(open|filtered)" nmap.txt; then
	echo -e "I can see port ${GREEN}80${NC}!"
else
	echo -e "Uh oh, port ${RED}80${NC} isn't showing up..."
	OPEN=0
fi

if grep -qE "^443/.*(open|filtered)" nmap.txt; then
	echo -e "I can see port ${GREEN}443${NC} as well!"
else
	echo -e "Uh oh, port ${RED}443${NC} isn't showing up..."
	OPEN=0
fi
rm nmap.txt
echo ""
if [[ $OPEN -eq 0 ]]; then
	echo -e "${RED}Port configuration needed.${NC} Something (probably your wireless router) is blocking us from serving this page to the rest of the internet."
       echo "Port forwarding is relatively simple, but as it stands it is beyond the scope of this script to be able to automate it."
       echo -e "You'll probably need to look up the login information for your specific router and forward the red ports to the local IP of this computer (${BOLD}$(ip route | grep default | grep -oP "(?<=src )[^ ]+")${NC})."
       echo -e "You can log into your router at this IP address: ${BOLD}$(route -n | grep ^0.0.0.0 | awk '{print $2}')${NC}"
       echo "That's all the help I can give you regarding port forwarding. Good luck!"
       echo ""
fi

echo "Okay, well that's everything! As long as your ports are forwarded, you should be ready to continue your WordPress setup by opening $domain in your browser."


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
