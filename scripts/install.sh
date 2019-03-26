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

guiText "Gather information required for the installation" "Section"

install_user=$(getCurrentUser)

guiText "Installing system for $install_user" "Comment"

valid_answers=("[Y n]")
install_software=$(ask "Install software (Y/n)" "${valid_answers[@]}")
export install_software

guiText "Checking for tools required for the installation process" "Section"

guiText "Checking for existing mariadb setup" "Section"
# MYSQL ROOT PASSWORD

#db_response=$(command "("/opt/local/lib/mariadb-10.2/bin/mysql -u root mysql -e 'SHOW TABLES'")" "false")
#echo "$test_password"
allowed_mariadb_server=("mariadb-10.2-server")
mariadb_check=$(isInstalled "port installed" "${allowed_mariadb_server[@]}")

if [ "$mariadb_check" = "Not Installed" ]; then
    echo "$mariadb_check"
    echo 
    echo "Installer will continue and install mariadb"
else
    if [ -e "/srv/tools/scripts/password.txt" ];then
	    sudo rm /srv/tools/scripts/password.txt
    fi
    root_password_status=$(/opt/local/lib/mariadb-10.2/bin/mysql -u root mysql -e 'SHOW TABLES' &> /srv/tools/scripts/password.txt)
    test_password=$(grep "using password: NO" /srv/tools/scripts/password.txt || echo "")
    if [ -z "$test_password" ];
    then 
        while [ "$test_password" ]
        do
            valid_password=("[A-Za-z0-9 \! \@ \— ]{8,30}")
            maria_db_password=$(ask "Enter password" "${valid_password[@]}" "true" )
            echo
            verify_maria_db_password=$(ask "Verify password" "${valid_password[@]}" "true")
            echo
            if [ "$maria_db_password" != "$verify_maria_db_password" ]; then
                echo "Password do not match"
                echo "Try again"
                echo
            else
                echo "Password match"
                command "sudo /opt/local/lib/mariadb-10.2/bin/mysqladmin -u root password '"$maria_db_password"'" 
            fi
        done
    else
        echo "Password previously set"
    fi
    sudo rm /srv/tools/scripts/password.txt
fi


# SETTING DEFAULT GIT USER
guiText "Setting Default GIT USER" "Section"
git config --global core.filemode false
#git config --global user.name "$install_user"
#git config --global user.email "$install_email"

# Checks if git credential are allready set, promts for input if not
gitConfigured "name"
gitConfigured "email"

git config --global credential.helper cache
command "sudo chown $install_user:staff /Users/$install_user/.gitconfig"

# Array containing major releases of Xcode

guiText "xcode" "Check"
xcode_array=( "Xcode 4" "Xcode 5" "Xcode 6" "Xcode 7" "Xcode 8" "Xcode 9" "Xcode 10" )
upgrade "$( isInstalled "xcodebuild -version" "${xcode_array[@]}" )"


guiText "Xcode command line tools version" "Check"
xcode_array_cl=( "version: 6" "version: 7" "version: 8" "version: 9" "version: 10" )
upgrade "$(isInstalled "pkgutil --pkg-info=com.apple.pkg.CLTools_Executables" "${xcode_array_cl[@]}")" "" "xcode-select --install"


guiText "Macports" "Check"
macports_array=("Version: 2")
upgrade "$(isInstalled "port version" "${macports_array[@]}")"


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