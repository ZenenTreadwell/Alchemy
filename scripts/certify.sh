#!/bin/bash

# Installs certbot and runs it
# ~ Zen, 2022

if [ -f "/etc/debian_version" ]; then
	DISTRO="debian"
	echo "Debian, Ubuntu, or Raspbian OS detected."
elif [ -f "/etc/arch-release" ]; then
	DISTRO="arch"
	echo "Arch- or Manjaro-based OS detected."
elif [ $(uname | grep -c "Darwin") -eq 1 ]; then
	DISTRO="mac"
	echo "MacOS detected."
else
	echo "I don't know what OS you're running! Cancelling this operation."
	exit 1
fi

echo ""

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
                "mac")
                    brew install $package
                    ;;
            esac

        else
            echo $package 'already installed!'
        fi
    done

}

install_if_needed certbot python3-certbot-nginx
sudo certbot --nginx
