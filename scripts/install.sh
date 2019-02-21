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
xcode_array=("Xcode 4" "Xcode 5" "Xcode 6" "Xcode 7" "Xcode 8" "Xcode 9" "Xcode 28")
guiText "Checking for xcode" "Comment"
for item in "${xcode_array[@]}"
do
    test_xcode=$(isInstalled "xcodebuild -version" "Xcode" "$item")
    export test_xcode
done
testContent "$test_xcode"
xcode_array_cl=("version: 6" "version: 7" "version: 8" "version: 9" "version: 28")
guiText "Checking Xcode command line tools version" "Comment"
for item in "${xcode_array_cl[@]}"
do
    test_xcode_cl=$(isInstalled "pkgutil --pkg-info=com.apple.pkg.CLTools_Executables" "version:" "$item")
    export test_xcode_cl
done
testContent "$test_xcode_cl"

guiText "Checking for Macports" "Comment"
test_macports=$(isInstalled "port version" "Version:" "Version: 2")
export test_macports
testContent "$test_macports"

guiText "Test of read" "Comment"
read -p "Do something: " something
echo $something













echo "Install complete"
echo "--------------------------------------------------------------"
echo ""