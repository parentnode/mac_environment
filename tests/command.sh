#!/bin/bash -e
source /srv/sites/parentnode/mac_environment/scripts/functions.sh
echo "with ouput" 
command "sudo ls /"
echo "without ouput"
command "sudo ls -Fla" "true" 