outputHandler "section" "Checking Required files/folders and shortcuts"

conf_path="/srv/tools/conf"
if [ $(fileExist "$conf_path/httpd.conf") = "false" ]; then
    echo "Required file is missing from your configuration source"
fi
if [ $(fileExist "$conf_path/httpd-vhosts.conf") = "false" ]; then
    echo "Required file is missing from your configuration source"
fi
if [ $(fileExist "$conf_path/php.ini") = "false" ]; then
    echo "Required file is missing from your configuration source"
fi
if [ $(fileExist "$conf_path/my.cnf") = "false" ]; then
    echo "Required file is missing from your configuration source"
fi
if [ $(fileExist "$conf_path/apache.conf") = "false" ]; then
    echo "Required file is missing from your configuration source"
fi
#checkFile "$conf_path/httpd-vhosts.conf" "Required file is missing from your configuration source"
#checkFile "$conf_path/php.ini" "Required file is missing from your configuration source"
#checkFile "$conf_path/my.cnf" "Required file is missing from your configuration source"
#checkFile "$conf_path/apache.conf" "Required file is missing from your configuration source"

#// TODO: create .bash_profile if it does not exist
#// Has not been tested
if [ $(fileExist "/Users/$install_user/.bash_profile") = "false" ]; then
    echo "Creating .bash_profile"
    copyFile "/srv/tools/conf/bash_profile_full.default" "/Users/$install_user/.bash_profile"
else 
    echo "Existing .bash_profile"
fi
#checkFileOrCreate "/Users/$install_user/.bash_profile" "/srv/tools/conf/bash_profile.start"
checkFolderExistOrCreate "/Users/$install_user/sites"
#
sudo chown $install_user:staff ~/Sites

checkFolderExistOrCreate "/srv"
if [ -d "/srv/sites" ]; then 
    echo "/srv/sites exists"
else
    echo "Creating symlink"
    sudo ln -s /Users/$install_user/Sites /srv/sites
fi

checkFolderExistOrCreate "/Users/$install_user/sites/apache" 
checkFolderExistOrCreate "/Users/$install_user/sites/apache/logs"

echo "Checking Directories done"