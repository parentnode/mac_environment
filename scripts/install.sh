#!/bin/bash


source ./functions.sh

# Current Username logged in
install_user=$(getUsername)
export install_user

# Request sudo privileges
enableSuperCow
outputHandler "comment" "DO NOT CLOSE UNTIL INSTALL IS COMPLETE" "You will see 'Install complete' message once it's done"

#outputHandler "comment" "Running this installer for user: $install_user"
# This is where you choose what to install and informs you what you don't need

. ./pre_install_check.sh

# This is where we make sure you have all the files and folders needed to install the script if not the script will create them
. ./checking_directories.sh

# This is where all the software packages and update installs are happening 
. ./install_software.sh

# This is were all the after installation configuration setup are completed configurations are moved to where they belong and files are edited to support the stack
. ./post_install_setup.sh


echo "--------------------------------------------------------------"
echo "Install complete"
echo "--------------------------------------------------------------"
echo ""

outputHandler "comment" "More info found at:" "https://parentnode.dk/blog/installing-the-web-stack-on-mac-os"
outputHandler "comment" "Restart your terminal, if you want to use " "MacOS Webstack commands"