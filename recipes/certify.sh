#!/bin/sh

# Installs certbot and runs it
# -- Bare Metal Alchemist, 2022

source ingredients/lead

install_if_needed certbot python3-certbot-nginx
sudo certbot --nginx
