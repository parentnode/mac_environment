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

guiText "xcode" "Check"
xcode_array=( "Xcode 4" "Xcode 5" "Xcode 6" "Xcode 7" "Xcode 8" "Xcode 9" "Xcode 10" )
is_ok_xcode=$( isInstalled "xcodebuild -version" "${xcode_array[@]}" )
if [ "$is_ok_xcode" = "Not Installed" ]; then
    echo "$is_ok_xcode"
    guiText "0" "Exit"
else
    echo "$is_ok_xcode"
fi

guiText "Xcode command line tools version" "Check"
xcode_array_cl=( "version: 6" "version: 7" "version: 8" "version: 9" "version: 10" )
is_ok_xcode_cl=$(isInstalled "pkgutil --pkg-info=com.apple.pkg.CLTools_Executables" "${xcode_array_cl[@]}")
if [ "$is_ok_xcode_cl" = "Not Installed" ]; then
    echo "$is_ok_xcode_cl"
    command "xcode-select --install"
    guiText "0" "Exit"
else
    echo "$is_ok_xcode_cl"
fi

guiText "Macports" "Check"
macports_array=("Version: 1" "Version: 2.4.3")
is_ok_macports=$(isInstalled "port version" "${macports_array[@]}")
if [ "$is_ok_macports" = "Not Installed" ]; then
    echo "$is_ok_macports"
    guiText "0" "Exit"
else
    echo "$is_ok_macports"
fi

#guiText "Test of read" "Comment"
#read -p "So you want to father a folder give it a name: " something
#mkdir -p "/Users/$install_user/Desktop/$something"

#output("\nChecking paths");

guiText "Checking Required files/folders and shortcuts" "Section"
conf_path="/srv/tools/conf"
checkFile "$conf_path/httpd.conf" "Required file is missing from your configuration source"
checkFile "$conf_path/httpd-vhosts.conf" "Required file is missing from your configuration source"
checkFile "$conf_path/php.ini" "Required file is missing from your configuration source"
checkFile "$conf_path/my.cnf" "Required file is missing from your configuration source"
checkFile "$conf_path/apache.conf" "Required file is missing from your configuration source"

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