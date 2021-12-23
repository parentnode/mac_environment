#!/bin/bash -e


# https://trac.macports.org/wiki/Migration

echo "-----------------------------------------------------"
echo ""
echo "                  Migrating MacPorts"
echo ""
echo "-----------------------------------------------------"
echo ""
echo "          Following process might take some time"

sudo ls &>/dev/null
echo ""


# Should check 
# - if port is working
# - if xcode license has been agreed to
# - if command-line tools are installed


# Check commandline tools
xcode_cl_ok=$(xcode-select -p 2>&1 | grep "Xcode.app/Contents/Developer")
if [ -z "$xcode_cl_ok" ]; then

	echo ""
	echo "You must install commandline tools"
	echo ""

	xcode-select --install

	echo
	echo "Run the setup command again when the command line tools are installed. See you again."
	echo
	exit 1;
fi


xcode_license=$(gcc --version 2>&1 | grep "license" || echo "" )
if [ -n "$xcode_license" ]; then

	sudo xcodebuild -license accept

fi


macports_updated=$(sudo port selfupdate 2>&1 | grep "does not match expected platform" || echo "" )
if [ -n "$macports_updated" ]; then
	echo ""
	echo "Update MacPorts first (go to macports.org and download MacPorts installer)"
	exit 1;
fi


# Make sure the latest version is installed
# sudo port selfupdate

# Export macports
sudo port -qv installed > myports.txt

# Export request history
sudo port echo requested | cut -d ' ' -f 1 | uniq > requested.txt

# Uninstall everything
sudo port -f uninstall installed

#Run a regular clear out of your installation
sudo port reclaim

# Clean any partially-completed builds
sudo rm -rf /opt/local/var/macports/build/*

# Download and execute the restore_ports script
sudo curl --location --remote-name https://github.com/macports/macports-contrib/raw/master/restore_ports/restore_ports.tcl
sudo chmod +x restore_ports.tcl
#sudo xattr -d com.apple.quarantine restore_ports.tcl

# Reinstall
sudo ./restore_ports.tcl myports.txt

# Reset history
sudo port unsetrequested installed
xargs sudo port setrequested < requested.txt


sudo port load apache2
sudo port load redis


# Clean up
# delete myports.txt
rm myports.txt
# delete requested.txt
rm requested.txt
# delete restore_ports.tcl
rm restore_ports.tcl



echo ""
echo "Thank you. Goodbye."
echo ""
