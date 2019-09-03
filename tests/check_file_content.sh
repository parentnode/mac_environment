#!/bin/bash -e
source /srv/sites/parentnode/mac_environment/scripts/functions.sh
current_username=$(getUsername)
checkFileContent "alias" "/Users/$current_username/.bash_profile"