#!/bin/bash -e
source /srv/sites/parentnode/mac_environment/scripts/functions.sh

#copyFile "/Users/$(getUsername)/Desktop/ouputs.sh" "/Users/$(getUsername)/Desktop/copied_output.sh"
if [ -f "/Users/$(getUsername)/Desktop/ouputs.sh" ]; then
    echo "im real and im here"
fi