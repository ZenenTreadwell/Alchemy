#!/bin/sh

# Script for installing a simple Flask server and deploying it
# Bare Metal Alchemist, 2022

source ingredients/lead
source ingredients/iron
source ingredients/copper

clear
say "${BLUE}"
say "                                                  ${AAAAAAAAAAAA}  &&&&&&&&&&&        "      
say "                                                  ${AAAAAAAAAAAA}  &@       &&        "      
say "                                                  ${AAAAAAAAAAAA}   &@     &&         "      
say "                                                  ${AAAAAAAAAAAA}   &@     &&         "      
say "${RESET} 8888888888 888                   888     ${BLUE}          /&&     @&         "      
say "${RESET} 8888888888 888                   888     ${BLUE}         @&#    &&&&&,       "      
say "${RESET} 888        888                   888     ${BLUE}        #&.         /&/      "      
say "${RESET} 888        888                   888     ${BLUE}       &&            *&@     "      
say "${RESET} 8888888    888  8888b.  .d8888b  888  888${BLUE}      &&           &&&&&@    "      
say "${RESET} 888        888     '88b 88K      888 .88P${BLUE}     &&                 &&   "      
say "${RESET} 888        888 .d888888 'Y8888b. 888888K ${BLUE}    &@                   &&  "      
say "${RESET} 888        888 888  888      X88 888 '88b${BLUE}   &&                    .&@ "      
say "${RESET} 888        888 'Y888888  88888P' 888  888${BLUE}    (&&&&&&&&&&&&&&&&&&&&&.  "      
say "${RESET}"

# ------------------- Step 1 - Baseline Setup -------------------

say "${BOLD}Hi again!${RESET} Looks like you want to get ${BLUE}Flask${RESET} up and running."
say "Well, as an alchemy-themed toolkit, I must say: ${GREEN}good decision :)${RESET}"
say ""

# Make sure this script isn't being run with sudo in front
if [ "$EUID" -eq 0 ]; then
    say "${RED}${BOLD}Woah there!${RESET} Seems you're running this script as a superuser."
    say ""
    say "That might cause some issues with permissions and whatnot. Run this script as your default user (without sudo) and I'll ask you when I need superuser permissions"
    say ""
    exit 1
fi

say "${ULINE}Making sure we've got the basics...${RESET}"
echo -e "(you'll probably need to input ${BLUE}your 'sudo' password${RESET} here)"
case $DISTRO in
    "debian")
        say "HEY I HAVEN'T TESTED THIS BY THE WAY"
        install_if_needed python python-pip
        pip install --upgrade pip
        ;;
    "arch")
        install_if_needed python python-pip
        python -m pip install --upgrade pip
        ;;
    "mac")
        say "HEY I HAVEN'T TESTED THIS BY THE WAY"
        install_if_needed python python-pip
        pip install --upgrade pip
        ;;
    "fedora")
        say "HEY I HAVEN'T TESTED THIS BY THE WAY"
        install_if_needed python python-pip
        pip install --upgrade pip
        ;;
esac
echo ""

while [ ! -d "$FLASK_DIR" ]; do
    ask_for FLASK_DIR "Please enter the path you would like to install \
Flask to (or enter nothing for ${BLUE}~/flask${RESET}): "
    if [ -z "$FLASK_DIR" ]; then
        remember "FLASK_DIR=$HOME/flask"
    fi
    say ""
    ask_for CONFIRM "Okay, should we install to \
${BLUE}${FLASK_DIR}${RESET}? ${BLUE}(y/n)${RESET} "

    case $CONFIRM in
        "Y" | "y")
            mkdir -p $FLASK_DIR
            ;;
    esac
done

# ------------------- Step 2 - Create venv -------------------

if [ -d "$FLASK_VENV" ]; then
    say "We already have a virtualenv folder for Flask here: ${BLUE}$FLASK_VENV${RESET}"
else
    say "Creating virtual environment for Flask"
    python -m venv $FLASK_DIR/venv
    remember FLASK_VENV=$FLASK_DIR/venv
fi

if [ "$VIRTUAL_ENV" != "$FLASK_VENV" ]; then
    say "Sourcing the virtual environment"
    source ${FLASK_VENV}/bin/activate
fi

say "Making sure we've got all the python packages we need!"
pip install -r resources/flask/requirements.txt
say ""

# ------------------- Step 3 - Build Flask -------------------

say "${BOLD}We've got everything!${RESET} I'm going to set you up with \
a basic Flask page now\n"

mkdir -p ${FLASK_DIR}/{templates,static}
cp resources/flask/app.py ${FLASK_DIR}
cp resources/flask/demo.css ${FLASK_DIR}/static
cp resources/flask/demo.html ${FLASK_DIR}/templates
say "Flask directory initialized, setting up reverse proxy\n"

# ------------------- Step 4 - NGINX Setup -------------------

 initialize_nginx
 make_site flask "FILE_ROOT=${FLASK_DIR}"
 say ""
 configure_domain_for_site flask
 enable_ssl

 say "Excellent! We've configured this computer to serve this Flask\
 server from ${BLUE}${ACCESS_POINT}:5000${RESET}"

# ------------------- Step 5 - Service Configuration -------------------

build_service_from_template flask "GUNICORN=`which gunicorn`" \
"FLASK_DIR=${FLASK_DIR}" "PORT=5000"
say ""
activate_service flask

say "${BOLD}\nAaaand, we're done!${RESET}\nAs long as everything \
worked properly, you should be able to visit your flask server at \
${BLUE}${ACCESS_POINT}:5000${RESET}"
say "\nThe main file is located in ${BLUE}${FLASK_DIR}${RESET}, other recipes may rely \
on making further modifications to this application. Take a look, and \
don't forget to experiment!"


exit 0
