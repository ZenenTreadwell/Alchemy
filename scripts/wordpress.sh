#!/bin/bash

# Downloads and configures Wordpress onto the current system
# Zen, 2022

# Font decoration for better a e s t h e t i c
RED="\e[0;91m"
GREEN="\e[0;92m"
BLUE="\e[0;94m"
BOLD="\e[1m"
ULINE="\e[4m"
NC="\e[0m"

# ------------------- Step 1  - Installing / Configuring MariaDB -------------------

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

install_if_needed mariadb-server php php-fpm php-mysql nginx

echo ""

read -p "Do you want to secure the database for production deployment? (y/n): " -n1 boot
echo ""
case $boot in
    y | Y)
        echo "Securing database..."
        sudo mysql_secure_installation
        ;;
esac
echo ""

MATCH=0
while [[ MATCH -eq 0 ]]; do
    read -sp "Enter the password that you would like to use for MariaDB: " pass
    echo ""
    read -sp "Please confirm your password: " pass2
    echo ""
    if [[ "$pass" == "$pass2" ]]; then
        MATCH=1
        sudo mariadb -e "CREATE DATABASE wordpress;"
        sudo mariadb -e "GRANT ALL ON wordpress.* TO '${USER}'@'localhost' IDENTIFIED BY '${pass}' WITH GRANT OPTION;"
        sudo mariadb -e "FLUSH PRIVILEGES;"
    else 
        echo "Passwords did not match :("
        echo ""
    fi
done

# ------------------- Step 2 - Downloading / Configuring WordPress -------------------

if [[ -e 'resources/wordpress.tar.gz' ]]; then
    echo "Wordpress already downloaded!"
else
    echo -e  "${ULINE}Downloading Wordpress...${NC}"
    curl -o resources/wordpress.tar.gz 'https://wordpress.org/latest.tar.gz'
fi

WP_DIR=""
while [[ -z $WP_DIR ]]; do
    echo ""
    echo "Where would you like to place the wordpress directory? Enter a path or leave blank for $HOME: "
    read -e WP_DIR

    if [[ -z $WP_DIR ]]; then
        WP_DIR=$HOME
    fi

    if [[ -d $WP_DIR ]]; then
        echo "Saving to $WP_DIR"
    else
        echo ""
        echo "Sorry, $WP_DIR doesn't seem like a valid directory to me..."
        WP_DIR=""
        echo "$WP_DIR"
    fi
done

if [[ -z $(ls -A $WP_DIR/wordpress) ]]; then
    tar -xzvf resources/wordpress.tar.gz --directory $WP_DIR
    echo "Wordpress has been extracted to $WP_DIR"!
else
    echo "Oh! It's already there."
fi

echo ""
echo "Configuring wordpress..."
cp $WP_DIR/wordpress/wp-config-sample.php $WP_DIR/wordpress/wp-config.php
sed -i 's/database_name_here/wordpress/' $WP_DIR/wordpress/wp-config.php
sed -i "s/username_here/${USER}/" $WP_DIR/wordpress/wp-config.php
sed -i "s/password_here/${pass}/" $WP_DIR/wordpress/wp-config.php

# while this phrase exists, replace it with a seed phrase
while grep -q 'put your unique phrase here' $WP_DIR/wordpress/wp-config.php; do
    SEED=$(echo $RANDOM | md5sum | awk {'print $1'})
    sed -i "0,/put your unique phrase here/s//${SEED}/" $WP_DIR/wordpress/wp-config.php
done
echo "Done!"

# ------------------- Step 3 - NGINX Setup -------------------
echo ""
echo "We might need to query DNS records here..."
install_if_needed dig
echo ""
read -p "Do you have a domain name pointing to this computer? (y/n): " -n1 boot
echo ""
case $boot in
    y | Y)
        echo "Good to hear! What is it?"
	read -p "http://" domain
        ;;
    *)
	echo "Okay, let's just configure it to your external IP for now."
	domain=$(dig @resolver4.opendns.com myip.opendns.com +short)
	echo "Looks like you're running on ${domain}"
	;;
esac
echo ""
WP_NGINX_CONF=/etc/nginx/sites-available/wp
sudo cp resources/wordpress.nginx.conf $WP_NGINX_CONF
sudo sed -i "s#SERVER_NAME#${domain}#" $WP_NGINX_CONF
sudo sed -i "s#FILE_ROOT#${WP_DIR}/wordpress#" $WP_NGINX_CONF
sudo ln -s /etc/nginx/sites-available/wp /etc/nginx/sites-enabled/
echo ""
sudo systemctl reload nginx
echo "Excellent! We've configured $WP_NGINX_CONF to serve your WordPress site from $domain"
echo ""
# ------------------- Step 4 - Certbot -------------------
read -p "Would you like to enable SSL via Certbot? (y/n): " -n1 boot
echo ""
case $boot in
    y | Y)
	echo "Alright, let's get Certbot in here!"
	install_if_needed python3 certbot python3-certbot-nginx
	echo "${BOLD}Take it away, Certbot${NC}"
	sudo certbot --nginx
        ;;
    *)
	echo "Yea, SSL is lame anyways..."
	;;
esac
echo ""
echo "Okay, well that's everything! You should be ready to continue your WordPress setup by opening $domain in your browser."
