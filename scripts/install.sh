#!/bin/bash -e

echo "--------------------------------------------------------------"
echo ""
echo "Installing parentNode in mac"
echo "DO NOT CLOSE UNTIL INSTALL ARE COMPLETE" 
echo "You will see 'Install complete' message once it's done"
echo ""
echo ""

source /srv/tools/scripts/functions.sh

outputHandler "section" "Gather information required for the installation"

# Current Username logged in
install_user=$(getUsername)
export install_user

# Request sudo privileges
enableSuperCow

tester=$(sudo cat "/etc/synthethic.conf" | grep "srv")
if [ -z "$tester" ]
then
	echo "fuck no"
fi
outputHandler "comment" "Installing system for $install_user"
exit
# This is where you choose what to install and informs you what you don't need
. /srv/tools/scripts/pre_install_check.sh

# This is where we make sure you have all the files and folders needed to install the script if not the script will create them
. /srv/tools/scripts/check_directories.sh

# This is where all the software packages and update installs are happening 
. /srv/tools/scripts/install_software.sh

# This is were all the after installation configuration setup are completed configurations are moved to where they belong and files are edited to support the stack
. /srv/tools/scripts/setup_configurations.sh

outputHandler "comment" "More info found at: https://parentnode.dk/blog/installing-the-web-stack-on-mac-os"

echo "Install complete"
echo "--------------------------------------------------------------"
echo ""
