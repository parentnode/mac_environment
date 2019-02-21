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
xcode_array[0]="Xcode 4"
xcode_array[1]="Xcode 5"
xcode_array[2]="Xcode 6"
xcode_array[3]="Xcode 7"
xcode_array[4]="Xcode 8"
xcode_array[5]="Xcode 9"
xcode_array[6]="Xcode 10"

    
     #"Xcode\ 5" "Xcode\ 6" "Xcode\ 7" "Xcode\ 8" "Xcode\ 9" "Xcode\ 10")
guiText "Checking for xcode" "Comment"
for item in "${xcode_array[@]}"
do
    isInstalled "xcodebuild -version" "Xcode" $item
done

read -p "Do something: " something
echo $something













echo "Install complete"
echo "--------------------------------------------------------------"
echo ""