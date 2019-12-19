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

#checkFolderExistOrCreate "/Users/$install_user/Sites"

#checkFolderExistOrCreate "/srv"
outputHandler "comment" "Sites folder setup"
if [ -d "/srv" ]; then 
    #echo "/srv exists"
    catalina='10.15.[0-9]'  
    macos_version=$(sw_vers | grep -E "ProductVersion:" | cut -f2)
    macos_version_catalina=$(sw_vers | grep -E "ProductVersion:\t$catalina" | cut -f2)
    if [ "$macos_version" = "$macos_version_catalina" ]; then
        checkFolderExistOrCreate "/var/parentnode/sites"
        if [ ! -d "/Users/$install_user/Sites" ]; then 
            echo "Catalina need special treatment: Creating symlink for srv/sites"
    		sudo ln -s /var/parentnode/sites /Users/$install_user/Sites
        fi
    else
            echo "you are fine"
    fi
else
    checkFolderExistOrCreate "/srv"
    echo "Creating symlink"
    if [ ! -d "/srv/sites" ]; then
        checkFolderExistOrCreate "/Users/$install_user/Sites"
        sudo ln -s /Users/$install_user/Sites /srv/sites
    else
        echo "not needed for your setup"
    fi
fi
# Change localuser group of /Users/$install_user/Sites to staff 
sudo chown $install_user:staff /Users/$install_user/Sites

checkFolderExistOrCreate "/Users/$install_user/Sites/apache" 
checkFolderExistOrCreate "/Users/$install_user/Sites/apache/logs"
checkFolderExistOrCreate "/Users/$install_user/Sites/apache/ssl"
checkFolderExistOrCreate "/Users/$install_user/Sites/parentnode"
echo "Checking Directories done"