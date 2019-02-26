#!/bin/bash -e

echo "--------------------------------------------------------------"
echo ""
echo "Installing parentNode in mac"
echo "DO NOT CLOSE UNTIL INSTALL ARE COMPLETE" 
echo "You will see 'Install complete' message once it's done"
echo ""
echo ""

#
source /srv/tools/scripts/functions.sh

install_user=$(getCurrentUser)

guiText "Installing system for $install_user" "Comment"

guiText "Checking for tools required for the installation process" "Section"
# Array containing major releases of Xcode
xcode_array=("Xcode 4" "Xcode 5" "Xcode 6" "Xcode 7" "Xcode 8" "Xcode 9" "Xcode 10")
guiText "xcode" "Check"
for item in "${xcode_array[@]}"
do
    isInstalled "xcodebuild -version" "$item"
done


# Array containing major releases of Xcode command line tools
xcode_array_cl=("version: 6" "version: 7" "version: 8" "version: 9" "version: 10")
guiText "Xcode command line tools version" "Check"
for item in "${xcode_array_cl[@]}"
do
    isInstalled "pkgutil --pkg-info=com.apple.pkg.CLTools_Executables" "$item"
done

guiText "Macports" "Check"
isInstalled "port version" "Version: 2"


#guiText "Test of read" "Comment"
#read -p "So you want to father a folder give it a name: " something
#mkdir -p "/Users/$install_user/Desktop/$something"

#output("\nChecking paths");

guiText "Checking Required files/folders and shortcuts" "Section"

checkFile "conf/httpd.conf" "Required file is missing from your configuration source"
checkFile "conf/httpd-vhosts.conf" "Required file is missing from your configuration source"
checkFile "conf/php.ini" "Required file is missing from your configuration source"
checkFile "conf/my.cnf" "Required file is missing from your configuration source"
checkFile "conf/apache.conf" "Required file is missing from your configuration source"

#// TODO: create .bash_profile if it does not exist
#// Has not been tested
checkFileOrCreate "~/.bash_profile" "/srv/tools/conf/bash_profile.start"

checkPath "~/Sites"

sudo chown $install_user:staff ~/Sites

checkPath "/srv"
if [ ! -f "/srv/sites" ]; then 
    sudo ln -s ~/Sites /srv/sites
fi

checkPath "~/Sites/apache" 
checkPath "~/Sites/apache/logs"

# Software script
#bash /srv/tools/scripts/install_software.sh





guiText "mac" "Link"

echo "Install complete"
echo "--------------------------------------------------------------"
echo ""