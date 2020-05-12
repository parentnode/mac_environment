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
    copyFile "/srv/tools/conf/dot_profile" "/Users/$install_user/.bash_profile"
else 
    echo "Existing .bash_profile"
fi

#checkFolderExistOrCreate "/Users/$install_user/Sites"
outputHandler "comment" "Sites folder setup"
#checkFolderExistOrCreate "/Users/$install_user/Sites"

if [ ! -d /srv/sites ]; then 
    if [ ! -d ~/Sites ]; then
        mkdir ~/Sites
        catalina='10.15.[0-9]'
        macos_version=$(sw_vers | grep -E "ProductVersion:" | cut -f2)
        macos_version_catalina=$(sw_vers | grep -E "ProductVersion:\t$catalina" | cut -f2)
        if [ "$macos_version" = "$macos_version_catalina" ]; then
            if [ ! -d /var/parentnode ]; then
                sudo mkdir /var/parentnode
                sudo chown $(logname):staff /var/parentnode
            fi
        fi
        sudo chown $install_user:staff ~/Sites
    fi
#checkFolderExistOrCreate "/srv"
        sudo ln -s ~/Sites /srv/sites
fi

# Change localuser group of /Users/$install_user/Sites to staff 

checkFolderExistOrCreate "/Users/$install_user/Sites/apache" 
checkFolderExistOrCreate "/Users/$install_user/Sites/apache/logs"
checkFolderExistOrCreate "/Users/$install_user/Sites/apache/ssl"
#checkFolderExistOrCreate "/Users/$install_user/Sites/parentnode"
outputHandler "comment" "Checking Directories Done"