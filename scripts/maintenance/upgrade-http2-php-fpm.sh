#!/bin/bash -e

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



outputHandler "comment" "Installing apache2 with http2 + PHP-FPM"



# # Get installed version of apache
# active_apache=$(port installed | grep apache2)
# if [ -n "$active_apache" ]; then
#
# 	active_apache="${active_apache/ (active)/}"
# 	outputHandler "comment" "Uninstall current apache2, $active_apache"
#
# 	command "sudo port uninstall $active_apache -f"
#
# fi
#
# 	# command "sudo port uninstall apache2"
#
# command "sudo port uninstall php82-apache2handler"

command "sudo port -N install php82-fpm"
command "sudo port -N install apache2 +eventmpm +http2"
command "sudo port -N install mod_fcgid"


# Apache main configuration
sudo cp "$CONF_DIR/httpd.conf" "/opt/local/etc/apache2/httpd.conf"

# Update username in file to make apache run as current user (required to access vhosts in dropbox)
command "sudo chmod 777 /opt/local/etc/apache2/httpd.conf"
sudo sed -i '' "s/###USERNAME###/$INSTALL_USER/g" "/opt/local/etc/apache2/httpd.conf"
command "sudo chmod 644 /opt/local/etc/apache2/httpd.conf"


sudo cp "$CONF_DIR/httpd-autoindex.conf" "/opt/local/etc/apache2/extra/httpd-autoindex.conf"
sudo cp "$CONF_DIR/httpd-vhosts.conf" "/opt/local/etc/apache2/extra/httpd-deflate.conf"
sudo cp "$CONF_DIR/httpd-mpm.conf" "/opt/local/etc/apache2/extra/httpd-mpm.conf"
sudo cp "$CONF_DIR/httpd-ssl.conf" "/opt/local/etc/apache2/extra/httpd-ssl.conf"
sudo cp "$CONF_DIR/httpd-vhosts.conf" "/opt/local/etc/apache2/extra/httpd-vhosts.conf"
sudo cp "$CONF_DIR/httpd-autoindex.conf" "/opt/local/etc/apache2/extra/proxy-html.conf"


# Copy PHP-FPM conf
sudo cp "$CONF_DIR/php-fpm.conf" "/opt/local/etc/php82/php-fpm.conf"
sudo cp "$CONF_DIR/php-fpm-www.conf" "/opt/local/etc/php82/php-fpm.d/www.conf"
sudo sed -i '' "s/###USERNAME###/$INSTALL_USER/g" "/opt/local/etc/php82/php-fpm.d/www.conf"


# autostart apache on reboot
outputHandler "comment" "Autostart apache2"
command "sudo port load apache2"

# autostart PHP-FPM on reboot
outputHandler "comment" "Autostart PHP-FPM"
command "sudo port load php82-fpm"


# restart apache
apache restart


inactive_status=$(testCommandResponse "port echo inactive")
if [ -n "$inactive_status" ]; then 

	outputHandler "comment" "Uninstall inactive ports"
	command "sudo port uninstall inactive"

fi
