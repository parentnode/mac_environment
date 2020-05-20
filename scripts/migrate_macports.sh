#!/bin/bash -e


# https://trac.macports.org/wiki/Migration

echo "-----------------------------------------------------"
echo ""
echo "                    Migrating MacPorts"
echo ""
echo "-----------------------------------------------------"
echo ""

sudo ls &>/dev/null
echo ""


# Should check 
# - if port is working
# - if xcode license has been agreed to
# - if command-line tools are installed

xcode-select --install

sudo xcodebuild -license


# Make sure the latest version is installed
sudo port selfupdate

# Export macports
sudo port -qv installed > myports.txt

# Export request history
sudo port echo requested | cut -d ' ' -f 1 > requested.txt

# Uninstall everything
sudo port -f uninstall installed

# Clean any partially-completed builds
sudo rm -rf /opt/local/var/macports/build/*

# Download and execute the restore_ports script
sudo curl --location --remote-name https://github.com/macports/macports-contrib/raw/master/restore_ports/restore_ports.tcl
sudo chmod +x restore_ports.tcl

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
