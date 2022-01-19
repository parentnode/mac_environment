#!/bin/bash -e

if [ "$install_software" = "Y" ]; then

	outputHandler "section" "Installing Software"


	outputHandler "comment" "Installing pidof"
	command "sudo port -N install pidof"

	outputHandler "comment" "Installing MariaDB"
	command "sudo port -N install mariadb-10.5-server"

	outputHandler "comment" "Installing PHP74"
	command "sudo port -N install php74"

	outputHandler "comment" "Installing apache2"
	command "sudo port -N install apache2"

	outputHandler "comment" "Installing pear"
	command "sudo port -N install pear"

	outputHandler "comment" "Installing php74-apache2handler"
	command "sudo port -N install php74-apache2handler"

	outputHandler "comment" "Installing PHP74-mysql"
	command "sudo port -N install php74-mysql"

	outputHandler "comment" "Installing PHP74-openssl"
	command "sudo port -N install php74-openssl"

	outputHandler "comment" "Installing PHP74-mbstring"
	command "sudo port -N install php74-mbstring"

	outputHandler "comment" "Installing PHP74-curl"
	command "sudo port -N install php74-curl"

	outputHandler "comment" "Installing PHP74-zip"
	command "sudo port -N install php74-zip"

	outputHandler "comment" "Installing PHP74-iconv"
	command "sudo port -N install php74-iconv"

	outputHandler "comment" "Installing PHP74-imagick"
	command "sudo port -N install php74-imagick"

	outputHandler "comment" "Installing PHP74-igbinary"
	command "sudo port -N install php74-igbinary"

	outputHandler "comment" "Installing PHP74-redis"
	command "sudo port -N install php74-redis"

	outputHandler "comment" "Installing redis"
	command "sudo port -N install redis"


	# Select PHP74 as default PHP
	outputHandler "comment" "Set php74 as default"
	command "sudo port select --set php php74"

	# autostart apache on reboot
	outputHandler "comment" "Autostart apache2"
	command "sudo port load apache2"

	# autostart mariadb on reboot
	outputHandler "comment" "Autostart redis"
	command "sudo port load redis"


	# Additional check on mariadb install – due to continuous build issues
	mariadb_installed_array=("mariadb-10.5-server \@10.5.* \(active\)")
	mariadb_installed_specific=$(testCommandResponse "port installed" "$mariadb_installed_array")
	if [ -n "$mariadb_installed_specific" ]; then

		outputHandler "comment" "Installing runtime environment for MariaDB"


		# Stop MariaDB if it is running
		mariadb_status_array=("mysql|mariadb")
		mariadb_status=$(testCommandResponse "ps -Aclw" "${mariadb_status_array[@]}")
		if [ -n "$mariadb_status" ]; then 
			outputHandler "comment" "Stopping running instance of MariaDB $(sudo /opt/local/share/mariadb-10.5/support-files/mysql.server stop 2>/dev/null)"
		fi


		#mysql paths
		checkFolderExistOrCreate "/opt/local/var/run/mariadb-10.5" "sudo"
		checkFolderExistOrCreate "/opt/local/var/db/mariadb-10.5" "sudo"
		checkFolderExistOrCreate "/opt/local/etc/mariadb-10.5" "sudo"
		checkFolderExistOrCreate "/opt/local/share/mariadb-10.5" "sudo"


		#Mysql preparations
		command "sudo chown -R mysql:mysql /opt/local/var/db/mariadb-10.5"
		command "sudo chown -R mysql:mysql /opt/local/var/run/mariadb-10.5"
		command "sudo chown -R mysql:mysql /opt/local/etc/mariadb-10.5"
		command "sudo chown -R mysql:mysql /opt/local/share/mariadb-10.5"


		# copy my.cnf for MySQL (to override macports settings)
		command "sudo cp $CONF_DIR/my.cnf /opt/local/etc/mariadb-10.5/my.cnf"


		# Install tables
		if [ $(fileExist "/opt/local/var/db/mariadb-10.5/mysql") = "false" ]; then 
			outputHandler "comment" "Installing Database tables"
			command "sudo -u _mysql /opt/local/lib/mariadb-10.5/bin/mysql_install_db"
		fi


		# autostart mariadb on reboot
		outputHandler "comment" "Autostart mariadb"
		command "sudo port load mariadb-10.5-server"


	else 
		outputHandler "comment" "Mariadb was not installed correctly" "Please try installing Mariadb 10.5 again at a later time" "Run this install script again afterwards"
	fi


	# Update any outdated ports
	command "sudo port upgrade outdated"


	outputHandler "comment" "Software: OK"

else
	outputHandler "comment" "Skipping software installation"
fi
