outputHandler "section" "Checking Required files/folders and shortcuts"
# Just a shorthand for readability
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

if [ $(fileExist "/Users/$install_user/.bash_profile") = "false" ]; then
    echo "Creating .bash_profile"
    copyFile "/srv/tools/conf/bash_profile_full.default" "/Users/$install_user/.bash_profile"
else 
    echo "Existing .bash_profile"
fi

checkFolderExistOrCreate "/Users/$install_user/Sites"
# Change localuser group of /Users/$install_user/Sites to staff 
sudo chown $install_user:staff /Users/$install_user/Sites

checkFolderExistOrCreate "/srv"
if [ -d "/srv/sites" ]; then 
    echo "/srv/sites exists"
else
    echo "Creating symlink"
    sudo ln -s /Users/$install_user/Sites /srv/sites
fi

checkFolderExistOrCreate "/Users/$install_user/Sites/apache" 
checkFolderExistOrCreate "/Users/$install_user/Sites/apache/logs"
checkFolderExistOrCreate "/Users/$install_user/Sites/apache/ssl"
checkFolderExistOrCreate "/Users/$install_user/Sites/parentnode"
echo "Checking Directories done"