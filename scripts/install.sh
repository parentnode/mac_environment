#!/bin/bash -e

echo "--------------------------------------------------------------"
echo ""
echo "Installing parentNode in mac"
echo "DO NOT CLOSE UNTIL INSTALL ARE COMPLETE" 
echo "You will see 'Install complete' message once it's done"
echo ""
echo ""


source /srv/tools/scripts/functions.sh

install_user=$(getCurrentUser)

guiText "Installing system for $install_user" "Comment"
xcode_array=("Xcode 4" "Xcode 5" "Xcode 6" "Xcode 7" "Xcode 8" "Xcode 9" "Xcode 11")
guiText "Checking for xcode" "Comment"
for item in "${xcode_array[@]}"
do
    test=$(isInstalled "xcodebuild -version" "Xcode" "$item")
    export test
done
if [ -z $test];
then 
    echo "Not Installed"
else 
    echo "Installed"
fi
xcode_array_cl=("version: 6" "version: 7" "version: 8" "version: 9" "version: 11")
guiText "Checking Xcode command line tools version" "Comment"
for item in "${xcode_array_cl[@]}"
do
    isInstalled "pkgutil --pkg-info=com.apple.pkg.CLTools_Executables" "version:" "$item"
done
guiText "Checking for Macports" "Comment"
isInstalled "port version" "Version:" "Version: 2"

guiText "Test of read" "Comment"
read -p "Do something: " something
echo $something













echo "Install complete"
echo "--------------------------------------------------------------"
echo ""