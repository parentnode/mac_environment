#!/bin/bash -e
source /srv/sites/parentnode/mac_environment/scripts/functions.sh
# Check if program/service are installed
echo "Testing testCommand"
echo 
apache_status=("httpd")
echo "Checking Apache2.4 status: "
testCommand "ps -Aclw" "${apache_status[@]}"
echo
redis_status=("redis")
echo "Checking Redis status: "
testCommand "ps -Aclw" "${redis_status[@]}"
echo
echo "Checking unzip version: "
valid_version=("^UnZip ([6\.[0-9])")
testCommand "unzip -v" "${valid_version[@]}"

# Usage: returns a true if a program or service are located in the installed services or programs
# P1: kommando
# P2: array of valid responses