#!/bin/bash -e

echo "--------------------------------------------------------------"
echo ""
echo "Installing parentNode in mac"
echo "DO NOT CLOSE UNTIL INSTALL ARE COMPLETE" 
echo "You will see 'Install complete' message once it's done"
echo ""
echo ""

#
source /srv/tools/scripts/functions.sh

outputHandler "section" "Gather information required for the installation"

install_user=$(getUsername)
export install_user

enableSupercow


outputHandler "comment" "Installing system for $install_user"
exit 0


valid_answers=("[Y n]")
install_software=$(ask "Install software (Y/n)" "${valid_answers[@]}")
export install_software

bash /srv/tools/scripts/pre_install_check.sh
guiText "0" "Exit"
guiText "Checking Required files/folders and shortcuts" "Section"
conf_path="/srv/tools/conf"
checkFile "$conf_path/httpd.conf" "Required file is missing from your configuration source"
checkFile "$conf_path/httpd-vhosts.conf" "Required file is missing from your configuration source"
checkFile "$conf_path/php.ini" "Required file is missing from your configuration source"
checkFile "$conf_path/my.cnf" "Required file is missing from your configuration source"
checkFile "$conf_path/apache.conf" "Required file is missing from your configuration source"

#// TODO: create .bash_profile if it does not exist
#// Has not been tested
checkFileOrCreate "/Users/$install_user/.bash_profile" "/srv/tools/conf/bash_profile.start"

checkPath "/Users/$install_user/Sites"
#
sudo chown $install_user:staff ~/Sites

checkPath "/srv"
if [ -d "/srv/sites" ]; then 
    echo "/srv/sites exists"
else
    echo "Creating symlink"
    sudo ln -s /Users/$install_user/Sites /srv/sites
fi

checkPath "/Users/$install_user/Sites/apache" 
checkPath "/Users/$install_user/Sites/apache/logs"

## Software script
#if test "$install_software" = "Y"; then
#    bash /srv/tools/scripts/install_software.sh
#else
#    guiText "Skipping software installation" "Comment"
#fi

#test placeholder replacing
command "sudo chown $install_user:staff ~/Sites"

#mysql paths
checkPath "/opt/local/var/run/mariadb-10.2"
checkPath "/opt/local/var/db/mariadb-10.2"
checkPath "/opt/local/etc/mariadb-10.2"
checkPath "/opt/local/share/mariadb-10.2"


#Mysql preparations
command "sudo chown -R mysql:mysql /opt/local/var/db/mariadb-10.2"
command "sudo chown -R mysql:mysql /opt/local/var/run/mariadb-10.2"
command "sudo chown -R mysql:mysql /opt/local/etc/mariadb-10.2"
command "sudo chown -R mysql:mysql /opt/local/share/mariadb-10.2"


#// set permissions
command "sudo chown $install_user:staff ~/.gitconfig"


copyFile "/srv/tools/conf/my.cnf", "/opt/local/etc/mariadb-10.2/my.cnf" 

copyFile "/srv/tools/conf/httpd.conf" "/opt/local/etc/apache2/httpd.conf"

command "sudo chmod 777 /opt/local/etc/apache2/httpd.conf"

#// update username in file to make apache run as current user (required to access vhosts in dropbox)
replaceInFile "/opt/local/etc/apache2/httpd.conf" "###USERNAME###" $install_user

command "sudo chmod 644 /opt/local/etc/apache2/httpd.conf"

copyFile "/srv/tools/conf/httpd-vhosts.conf" "/opt/local/etc/apache2/extra/httpd-vhosts.conf"

copyFile "/srv/tools/conf/httpd-ssl.conf" "/opt/local/etc/apache2/extra/httpd-ssl.conf"

if [ ! -e "/srv/sites/apache/apache.conf" ]; then
    copyFile "/srv/tools/conf/apache.conf" "/srv/sites/apache/apache.conf"
    command "sudo chown -R $install_user:staff /Users/$install_user/Sites/apache"
fi     

copyFile "/srv/tools/conf/newsyslog-apache.conf" "/etc/newsyslog.d/apache.conf"

copyFile "/srv/tools/conf/php.ini" "/opt/local/etc/php72/php.ini"
#// copy php.ini.default for native configuration
#copyFile("conf/php_ini_native.ini", "/etc/php.ini", "sudo");
copyFile "/srv/tools/conf/php_ini_native.ini" "/etc/php.ini"


#output("\nConfiguration copied");

#// Add alias' to .bash_profile
#checkFileContent("~/.bash_profile", "conf/bash_profile.default");
#// set correct owner for .bash_profile
#command("sudo chown $username:staff ~/.bash_profile");


#// Add local domains to /etc/hosts
#command("sudo chmod 777 /etc/hosts");
#checkFileContent("/etc/hosts", "conf/hosts.default");
#command("sudo chmod 644 /etc/hosts");


#// start database
#command("sudo /opt/local/share/mariadb-10.2/support-files/mysql.server start",true);
#output("Starting MariaDB");

#email_array=("[A-Za-z0-9\.\-]+@[A-Za-z0-9\.\-]+\.[a-z]{2,10}")
#ask "Email" "${email_array[@]}"


guiText "mac" "Link"

echo "Install complete"
echo "--------------------------------------------------------------"
echo ""