#!/bin/bash

# Get path of this script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export SCRIPT_DIR

CONF_DIR="$(dirname "$SCRIPT_DIR")/conf"
export CONF_DIR

BIN_DIR="$(dirname "$SCRIPT_DIR")/bin"
export BIN_DIR


# Include functions
source $SCRIPT_DIR/functions.sh

# Current Username logged in
INSTALL_USER=$(getUsername)
export INSTALL_USER


# Request sudo privileges
enableSuperCow


# On newer systems MacPorts will install path in .zprofile not in .profile
# Path is needed to run port commands
checkProfile


outputHandler "section" "DO NOT CLOSE UNTIL INSTALL IS COMPLETE"
outputHandler "comment" "You will see an 'Install complete' message once installation is done"


# wait for 5 seconds before continuing
sleep 5


# install prerequisites
. $SCRIPT_DIR/install_prerequisites.sh


# This is where you choose what to install
. $SCRIPT_DIR/install_options.sh


# This is where we make sure you have the Sites folder set up correctly
. $SCRIPT_DIR/install_directories.sh


# This is where all the base software is installed
. $SCRIPT_DIR/install_software.sh


# This is where all ffmpeg is installed
. $SCRIPT_DIR/install_ffmpeg.sh


# This is where all wkhtml is installed
. $SCRIPT_DIR/install_wkhtml.sh


# This is were all the configuration is done
#. $SCRIPT_DIR/install_configuration.sh



outputHandler "section" "Install complete"


outputHandler "comment" "More info found at:" "https://parentnode.dk/blog/installing-the-web-stack-on-mac-os"
outputHandler "comment" "Restart your terminal to activate newly installed webstack commands"
