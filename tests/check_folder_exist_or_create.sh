#!/bin/bash -e
source /srv/sites/parentnode/mac_environment/scripts/functions.sh

checkFolderExistOrCreate "/Users/$(echo $(getUsername))/Sites/parentnode/mac_environment/tests/created_folder"