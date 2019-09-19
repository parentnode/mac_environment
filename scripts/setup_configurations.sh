echo "Setup Configuration"

copyFile "/srv/tools/conf/httpd.conf" "/opt/local/etc/apache2/httpd.conf"

command "sudo chmod 777 /opt/local/etc/apache2/httpd.conf"

#// update username in file to make apache run as current user (required to access vhosts in dropbox)
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
#// copy php.ini.default for native configuration
#copyFile("conf/php_ini_native.ini", "/etc/php.ini", "sudo");
copyFile "/srv/tools/conf/php_ini_native.ini" "/etc/php.ini"


echo "Configuration copied"

# Add alias' to .bash_profile
#if [ $(checkFileContent """~/.bash_profile" "conf/bash_profile.default")
#// set correct owner for .bash_profile
#command("sudo chown $username:staff ~/.bash_profile");


#// Add local domains to /etc/hosts
#command "sudo chmod 777 /etc/hosts"
#checkFileContent("/etc/hosts", "conf/hosts.default");
#command("sudo chmod 644 /etc/hosts");


#// start database
command "sudo /opt/local/share/mariadb-10.2/support-files/mysql.server start" "true"
outputHandler "comment" "starting mariadb"


if [ "$(checkMariadbPassword)" = "false" ]; then
    command "sudo /opt/local/lib/mariadb-10.2/bin/mysqladmin -u root password "$db_root_password1"" "true"
else 
    echo "password is sat"
fi
#email_array=("[A-Za-z0-9\.\-]+@[A-Za-z0-9\.\-]+\.[a-z]{2,10}")
#ask "Email" "${email_array[@]}"