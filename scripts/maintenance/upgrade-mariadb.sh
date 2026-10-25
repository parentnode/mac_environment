#!/bin/bash -e

# Include functions
source /srv/sites/parentnode/mac_environment/scripts/functions.sh

# Current Username logged in
INSTALL_USER=$(getUsername)
export INSTALL_USER


# Request sudo privileges
enableSuperCow


active_mariadb105=$(port installed | grep mariadb-10.5)
if [ -n "$active_mariadb105" ]; then

	./mysql_dump_all.php

	sudo port unload mariadb-10.5-server
	sudo port deactivate mariadb-10.5-server

fi

sudo port install mariadb-10.11-server
sudo port load mariadb-10.11-server


cp -r /opt/local/var/db/mariadb-10.5 /opt/local/var/db/mariadb-10.11


mariadb-upgrade -u root -p



inactive_status=$(testCommandResponse "port echo inactive")
if [ -n "$inactive_status" ]; then 

	outputHandler "comment" "Uninstall inactive ports"
	sudo port uninstall inactive

fi
