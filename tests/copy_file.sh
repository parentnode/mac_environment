#!/bin/bash -e
source /srv/sites/parentnode/mac_environment/scripts/functions.sh
install_user=$(getUsername)
#copyFile "/Users/$(getUsername)/Desktop/ouputs.sh" "/Users/$(getUsername)/Desktop/copied_output.sh"
if [ -e "/Users/$install_user/Desktop/ouputs.sh" ]; then
    echo "im real and im here now"
fi