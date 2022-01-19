#!/bin/bash


# Most prerequisites have been checked in install-loader
outputHandler "section" "Checking prerequisites"


outputHandler "comment" "Running this installer for user: $INSTALL_USER"


macos_version=$(sw_vers | grep -E "ProductVersion:" | cut -f2)
export macos_version
outputHandler "comment" "You are running macOS: ($macos_version)"


outputHandler "comment" "Selecting default Xcode"
command "sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer/"


# Check for already running apache
apache_status_array=("httpd")
apache_status=$(testCommandResponse "ps -Aclw" "${apache_status_array[@]}")
if [ -n "$apache_status" ]; then 
	outputHandler "comment" "Stopping running instance of Apache $(sudo apachectl stop 2>/dev/null)"
fi


outputHandler "comment" "Prerequisites: OK"
