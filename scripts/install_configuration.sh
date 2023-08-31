if [ "$install_configuration" = "Y" ]; then

	outputHandler "section" "Configuring webstack"


	# Check for .bash_profile, copy if it doesn't exist
	checkBashProfile



	# GIT

	outputHandler "comment" "Configuring GIT"

	# Ignore filemode changes as default
	git config --global core.filemode false
	# Store credentials
	git config --global credential.helper store

	# Checks if git credential are allready set, promts for input if not
	if [ -z "$(checkGitCredential "user.name")" ]; then
		git_username_array=("[A-Za-z0-9[:space:]*]{2,50}")
		git_username=$(ask "Enter git username" "${git_username_array[@]}" "git username")
		git config --global user.name "$git_username"
	fi

	if [ -z "$(checkGitCredential "user.email")" ]; then
		git_email_array=("[A-Za-z0-9\.\-]+@[A-Za-z0-9\.\-]+\.[a-z]{2,10}")
		git_email=$(ask "Enter git email" "${git_email_array[@]}" "git email")
		git config --global user.email "$git_email"
	fi

	# Set default git push mode
	if [ -z $(checkGitCredential "push.default") ]; then 
		command "git config --global push.default simple"
	fi

	# Change group of .gitconfig to user:staff 
	command "sudo chown $INSTALL_USER:staff /Users/$INSTALL_USER/.gitconfig"



	# APACHE

	outputHandler "comment" "Configuring Apache"

	# Apache main configuration
	copyFile "$CONF_DIR/httpd.conf" "/opt/local/etc/apache2/httpd.conf"

	# Update username in file to make apache run as current user (required to access vhosts in dropbox)
	command "sudo chmod 777 /opt/local/etc/apache2/httpd.conf"
	sed -i '' "s/###USERNAME###/$INSTALL_USER/g" "/opt/local/etc/apache2/httpd.conf"
	command "sudo chmod 644 /opt/local/etc/apache2/httpd.conf"

	copyFile "$CONF_DIR/httpd-vhosts.conf" "/opt/local/etc/apache2/extra/httpd-vhosts.conf"
	copyFile "$CONF_DIR/httpd-ssl.conf" "/opt/local/etc/apache2/extra/httpd-ssl.conf"

	# SSL certificates for *.local
	copyFile "$CONF_DIR/ssl/star_local.crt" "/srv/sites/apache/ssl/star_local.crt"
	copyFile "$CONF_DIR/ssl/star_local.key" "/srv/sites/apache/ssl/star_local.key"

	# Apache extension conf – copy if it does not exist
	if [ $(fileExist "/srv/sites/apache/apache.conf") = "false" ]; then
		copyFile "$CONF_DIR/apache.conf" "/srv/sites/apache/apache.conf"
		command "sudo chown -R $INSTALL_USER:staff /Users/$INSTALL_USER/Sites/apache"
	fi

	# Apache log file configuration
	copyFile "$CONF_DIR/newsyslog-apache.conf" "/etc/newsyslog.d/apache.conf"



	# PHP

	outputHandler "comment" "Configuring PHP"

	# PHP configurations
	# copyFile "$CONF_DIR/php-74.ini" "/opt/local/etc/php74/php.ini"
	# copyFile "$CONF_DIR/php-native-74.ini" "/etc/php.ini"
	copyFile "$CONF_DIR/php-82.ini" "/opt/local/etc/php82/php.ini"
	copyFile "$CONF_DIR/php-native-82.ini" "/etc/php.ini"



	# SYSTEM

	# Increase max open files (Apple's default settings has caused problems for MariaDB)
	if [ $(fileExist "/Library/LaunchDaemons/limit.maxfiles.plist") = "false" ]; then
		copyFile "$CONF_DIR/limit.maxfiles.plist" "/Library/LaunchDaemons/limit.maxfiles.plist"
		command "sudo chown root:staff /Library/LaunchDaemons/limit.maxfiles.plist"
		command "sudo chmod 644 /Library/LaunchDaemons/limit.maxfiles.plist"
		command "sudo launchctl load -w /Library/LaunchDaemons/limit.maxfiles.plist"
	fi

	# Increase max processes (Apple's default settings has caused problems for MariaDB)
	if [ $(fileExist "/Library/LaunchDaemons/limit.maxproc.plist") = "false" ]; then
		copyFile "$CONF_DIR/limit.maxproc.plist" "/Library/LaunchDaemons/limit.maxproc.plist"
		command "sudo chown root:staff /Library/LaunchDaemons/limit.maxproc.plist"
		command "sudo chmod 644 /Library/LaunchDaemons/limit.maxproc.plist"
		command "sudo launchctl load -w /Library/LaunchDaemons/limit.maxproc.plist"
	fi



	# MARIADB

	# Set root password if needed
	if [ "$set_db_root_password" = "true" ]; then

		outputHandler "comment" "Setting MariaDB root password"

		# Start database
		command "sudo /opt/local/share/mariadb-10.5/support-files/mysql.server start" "true"
		command "sudo /opt/local/lib/mariadb-10.5/bin/mysqladmin -u root password $db_root_password1" "true"

	fi



	# Start Apache
	command "sudo /opt/local/sbin/apachectl restart" "true"

	# Start MariaDB
	command "sudo /opt/local/share/mariadb-10.5/support-files/mysql.server start" "true"


	outputHandler "comment" "Configuration: OK"

else
	outputHandler "comment" "Skipping webstack configuration"
fi
