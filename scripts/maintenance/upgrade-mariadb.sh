#!/bin/bash

# Include functions
TOOLS_DIR="/srv/tools"

CONF_DIR="$TOOLS_DIR/conf"
export CONF_DIR

source "$TOOLS_DIR/scripts/functions.sh"
source "$CONF_DIR/dot_pnstack_aliases"


# Current Username logged in
INSTALL_USER=$(getUsername)
export INSTALL_USER


# Request sudo privileges
enableSuperCow

active_mariadb105=$(port installed | grep 'mariadb-10\.5')
if [ -n "$active_mariadb105" ]; then

	"$TOOLS_DIR/scripts/maintenance/mysql_dump_all.php"

	sudo port unload mariadb-10.5-server
	sudo port deactivate mariadb-10.5-server

fi


sudo port install mariadb-10.11-server
sudo port load mariadb-10.11-server


# Version 10.5 db exists
if [ -d "/opt/local/var/db/mariadb-10.5" ] && [ ! -f "/opt/local/var/db/mariadb-10.11/mysql" ]; then

	# Copy DBs to new 10.11 location
	sudo cp -r /opt/local/var/db/mariadb-10.5/ /opt/local/var/db/mariadb-10.11

	# Upgrade DBs
	sudo /opt/local/lib/mariadb-10.11/bin/mariadb-upgrade -u root -p

fi


inactive_status=$(port echo inactive)
if [ -n "$inactive_status" ]; then 

	outputHandler "comment" "Uninstall inactive ports"
	sudo port uninstall inactive

fi
