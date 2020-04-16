#!/bin/bash -e


source /srv/tools/scripts/functions.sh

# Current Username logged in
install_user=$(getUsername)
export install_user

# Request sudo privileges
enableSuperCow
outputHandler "section" "Installing parentNode in mac"
outputHandler "comment" "DO NOT CLOSE UNTIL INSTALL ARE COMPLETE" "You will see 'Install complete' message once it's done"

outputHandler "comment" "Installing system for $install_user"
# This is where you choose what to install and informs you what you don't need

. /srv/tools/scripts/pre_install_check.sh

# This is where we make sure you have all the files and folders needed to install the script if not the script will create them
. /srv/tools/scripts/check_directories.sh

# This is where all the software packages and update installs are happening 
. /srv/tools/scripts/install_software.sh

# This is were all the after installation configuration setup are completed configurations are moved to where they belong and files are edited to support the stack
. /srv/tools/scripts/post_install_setup.sh

outputHandler "comment" "More info found at: https://parentnode.dk/blog/installing-the-web-stack-on-mac-os"

echo "Install complete"
echo "--------------------------------------------------------------"
echo ""
