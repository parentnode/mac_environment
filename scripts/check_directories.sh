echo "Checking Directories"

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

echo "Checking Directories done"