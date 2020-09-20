#!/bin/bash
source /srv/tools/scripts/functions.sh

# Current Username logged in
install_user=$(getUsername)
export install_user

outputHandler "section" "Setting up parentNode webstack for a new mac user"


echo ""
echo "Checking system configuration for current user"

git config --global core.filemode false
git config --global credential.helper cache

# Checks if git credential are allready set, promts for input if not
if [ -z "$(checkGitCredential "user.name")" ]; then

	echo ""
	echo "Git username is missing for current user"

	git_username_array=("[A-Za-z0-9[:space:]*]{2,50}")
	git_username=$(ask "Enter git username" "${git_username_array[@]}" "gitusername")
	git config --global user.name "$git_username"
fi
if [ -z "$(checkGitCredential "user.email")" ]; then

	echo ""
	echo "Git email is missing for current user"

	git_email_array=("[A-Za-z0-9\.\-]+@[A-Za-z0-9\.\-]+\.[a-z]{2,10}")
	git_email=$(ask "Enter git email" "${git_email_array[@]}" "gitemail")
	git config --global user.email "$git_email"
fi
if [ -z $(checkGitCredential "push.default") ]; then 
	command "git config --global push.default simple"
fi


check_for_symlink=$(ls -l /srv/sites | grep /srv/sites | cut -d '>' -f2 | cut -d ' ' -f2)
if [ ! "$check_for_symlink" = ~/Sites ]; then
	echo "Creating Symlink"
	if [ ! -d ~/Sites ]; then
		mkdir ~/Sites
		mkdir ~/Sites/apache
		mkdir ~/Sites/apache/logs
		mkdir ~/Sites/apache/ssl

		copyFile "/srv/tools/conf/apache.conf" "/srv/sites/apache/apache.conf"
		copyFile "/srv/tools/conf/ssl/star_local.crt" "/srv/sites/apache/ssl/star_local.crt"
		copyFile "/srv/tools/conf/ssl/star_local.key" "/srv/sites/apache/ssl/star_local.key"

		chown -R $(getUsername):staff ~/Sites	
	fi

	if [ -d /var/parentnode ]; then 
		current_user_of_parentnode_folder=$(ls -l /var/ | grep parentnode | grep $(getUsername))
		if [ -z "$current_user_of_parentnode_folder" ]; then
			sudo chown -R $(logname):staff /var/parentnode
		fi
	fi

	unlink /srv/sites
	ln -s ~/Sites /srv/sites
fi


# Check existence of bash profile
checkBashProfile


# set bash as default terminal
current_shell=$(dscl . -read ~/ UserShell | grep bash)
if [ -z "$current_shell" ]; then
	chsh -s /bin/bash
fi



outputHandler "comment" "Setup is complete – you can close this window"

# open fresh terminal window
open -a Terminal .
