#!/bin/bash -e
source /srv/sites/parentnode/mac_environment/scripts/functions.sh
# Function checkGitCredential
# Check if credential are set
echo "Testing testGitCredential"
#Usage: check if there is value in

#Git.username
checkGitCredential "name"
#Git.email
checkGitCredential "email"