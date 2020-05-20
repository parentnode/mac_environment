#!/bin/bash -e
source /srv/sites/parentnode/mac_environment/scripts/functions.sh
# Check if program/service are installed
echo "Testing testCommandResponse"
echo 
apache_status=("httpd")
echo "Checking Apache2.4 status: "
#testCommandResponse "ps -Aclw" "${apache_status[@]}"
if [ "$(testCommandResponse "ps -Aclw" "${apache_status[@]}")" = "true" ]; then 
    echo "apache running"
else 
    echo "apache not running"
fi

# Usage: returns a true if a program or service are located in the installed services or programs
# P1: kommando
# P2: array of valid responses