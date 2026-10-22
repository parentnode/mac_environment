outputHandler "section" "Updating folders and shortcuts"

if [ ! -d /srv/sites ]; then 
	if [ ! -d ~/Sites ]; then
		mkdir ~/Sites
		catalina='10.15.[0-9]|1[1-9].[0-9]+'

		macos_version_catalina=$(sw_vers | grep -E "ProductVersion:\t$catalina" | cut -f2)
		if [ "$macos_version" = "$macos_version_catalina" ]; then
			if [ ! -d /var/parentnode ]; then
				sudo mkdir /var/parentnode
				sudo chown $INSTALL_USER:staff /var/parentnode
			fi
		fi

		sudo chown $INSTALL_USER:staff ~/Sites
	fi

	sudo ln -s ~/Sites /srv/sites
fi

# Change localuser group of /Users/$INSTALL_USER/Sites to staff 

checkFolderExistOrCreate "/Users/$INSTALL_USER/Sites/apache" 
checkFolderExistOrCreate "/Users/$INSTALL_USER/Sites/apache/logs"
checkFolderExistOrCreate "/Users/$INSTALL_USER/Sites/apache/ssl"


outputHandler "comment" "Folders and shortcuts: OK"