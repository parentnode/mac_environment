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
array=("Xcode 4", "Xcode 5", "Xcode 6", "Xcode 7", "Xcode 8", "Xcode 9", "Xcode 10")
for item in ${array[*]}
do
    isInstalled "xcodebuild -version" "Xcode" "$item"
done

read -p "Do something: " something
echo $something













echo "Install complete"
echo "--------------------------------------------------------------"
echo ""