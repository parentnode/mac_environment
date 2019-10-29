echo "Setup Configuration"

copyFile "/srv/tools/conf/httpd.conf" "/opt/local/etc/apache2/httpd.conf"

command "sudo chmod 777 /opt/local/etc/apache2/httpd.conf"

# Update username in file to make apache run as current user (required to access vhosts in dropbox)
replaceInFile "/opt/local/etc/apache2/httpd.conf" "###USERNAME###" $install_user

command "sudo chmod 644 /opt/local/etc/apache2/httpd.conf"

copyFile "/srv/tools/conf/httpd-vhosts.conf" "/opt/local/etc/apache2/extra/httpd-vhosts.conf"

copyFile "/srv/tools/conf/httpd-ssl.conf" "/opt/local/etc/apache2/extra/httpd-ssl.conf"

if [ $(fileExist "/srv/sites/apache/apache.conf") = "false" ]; then
    copyFile "/srv/tools/conf/apache.conf" "/srv/sites/apache/apache.conf"
    command "sudo chown -R $install_user:staff /Users/$install_user/Sites/apache"
fi     

copyFile "/srv/tools/conf/newsyslog-apache.conf" "/etc/newsyslog.d/apache.conf"

copyFile "/srv/tools/conf/php.ini" "/opt/local/etc/php72/php.ini"
# Copy php.ini.default for native configuration
copyFile "/srv/tools/conf/php_ini_native.ini" "/etc/php.ini"


echo "Configuration copied"

# Start database
command "sudo /opt/local/share/mariadb/support-files/mysql.server start" "true"
outputHandler "comment" "starting mariadb"

outputHandler "comment" "setting mariadb password"
if [ "$(checkMariadbPassword)" = "false" ]; then
    command "sudo /opt/local/lib/mariadb/bin/mysqladmin -u root password "$db_root_password1"" "true"
else 
    echo "password is sat"
fi
