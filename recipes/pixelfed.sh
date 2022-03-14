#!/bin/bash

# Downloads and configures Pixelfed onto the current system
# Zen, 2022

source ingredients/lead
source ingredients/iron

# ------------------- Step 1 - Database Setup -------------------

install_if_needed postgresql
DB_INIT_LOCATION="/var/lib/postgres/data"

if [ ! -n "$DB_INIT_LOCATION" ]; then
    say "Initializing Postgres DB to ${GREEN}$DB_INIT_LOCATION${RESET}"
    sudo -u postgres initdb --locale en_US.UTF-8 -D "$DB_INIT_LOCATION"
else
    say "Postgres already initalized!"
fi

activate_service postgresql

sudo -u postgres psql -c "CREATE USER IF NOT EXISTS pixelfed CREATEDB;" > /dev/null

exit 0


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
sudo cp resources/nginx/wordpress.nginx.conf $WP_NGINX_CONF
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
	echo -e "${BOLD}Take it away, Certbot${NC}"
	sudo certbot --nginx
        ;;
    *)
	echo "Yea, SSL is lame anyways..."
	;;
esac
echo ""

# ------------------- Step 5 - Port Testing -------------------

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
