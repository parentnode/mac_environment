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
	sudo port deactivate mariadb-10.5

fi


sudo port install mariadb-10.11-server


outputHandler "comment" "Configure MariaDB 10.11"

# sudo mkdir -p /opt/local/etc/mariadb-10.11
sudo cp $CONF_DIR/my.cnf /opt/local/etc/mariadb-10.11/my.cnf




# Version 10.5 DBs exists
if [ -d "/opt/local/var/db/mariadb-10.5" ]; then


	outputHandler "comment" "Copy MariaDB 10.5 data to 10.11"

	# Copy DBs to new 10.11 location
	if [ -d "/opt/local/var/db/mariadb-10.11" ]; then

		sudo cp -r /opt/local/var/db/mariadb-10.11/ /opt/local/var/db/mariadb-10.11-upgrade

	fi

	# Copy DBs to new 10.11 location
	sudo cp -r /opt/local/var/db/mariadb-10.5/ /opt/local/var/db/mariadb-10.11
	sudo chown -R _mysql:_mysql /opt/local/var/db/mariadb-10.11

	# Start mariadb
	sudo port load mariadb-10.11-server


	outputHandler "comment" "Upgrade existing tables for MariaDB 10.11"

	# Upgrade DBs
	sudo /opt/local/lib/mariadb-10.11/bin/mariadb-upgrade -u root -p


	outputHandler "comment" "Once you have varified that the upgrade went well (log in to db, check MariaDB version, DB's, tables and data), then you should consider deleting the old tables in /opt/local/var/db/mariadb-10.5"


else


	sudo -u _mysql /opt/local/lib/mariadb-10.11/bin/mariadb-install-db

	sudo port load mariadb-10.11-server



	outputHandler "comment" "Set MariaDB 10.11 password"

	sudo /opt/local/lib/mariadb-10.11/bin/mysqladmin -u root password

fi



inactive_status=$(port echo inactive)
if [ -n "$inactive_status" ]; then 

	outputHandler "comment" "Uninstall inactive ports"
	sudo port uninstall inactive

fi
