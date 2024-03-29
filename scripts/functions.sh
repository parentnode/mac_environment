#!/bin/bash -e

# Get username for current user, display and store for later use
getUsername() {
	echo "$(logname)"
}
export -f getUsername


# Invoke sudo command
enableSuperCow(){
	sudo ls &>/dev/null
}
export -f enableSuperCow


# Helper function for text output and format 
outputHandler(){
	#$1 - type eg. Comment, Section, Exit
	#$2 - text for output
	#$3,4,5 are extra text when needed
	case $1 in 
		"comment")
			echo
			echo "$2"
			if [ -n "$3" ];
			then
				echo "$3"
			fi
			if [ -n "$4" ];
			then
				echo "$4"
			fi
			if [ -n "$5" ];
			then
				echo "$5"
			fi
			if [ -z "$2" ];
			then
				echo "No comments"
			fi
			echo
			;;
		"section")
			length=$(((70-${#2})/2))
			echo 
			echo "----------------------------------------------------------------------"
			echo 
			echo "$(printf "%*s%s" $length '' "$2")"
			echo
			echo "----------------------------------------------------------------------"
			echo
			;;
		"exit")
			echo
			echo "$2 -- Goodbye see you soon"
			exit 0
			;;
		#These following commentary cases are used for installing and configuring setup
		*)
			echo 
			echo "Are you sure you wanted output here can't recognize: ($1)"
			echo
			;;

	esac
}
export -f outputHandler


# Asking user for input based on type
ask(){
	#$1 - output query text for knowing what to ask for.
	#$2 - array of valid chacters:
	#$3 - type eg. Password
	# If type is:  
	## Password hide prompt input, allow special chars, allow min and max length for the string 
	## Email: valid characters(restrict to email format (something@somewhere.com))
	## Username: valid characters(letters and numbers)
	valid_answers=("$2")
	
	
	if [ "$3" = "password" ]; then
		read -s -p "$1: "$'\n' question
	else 
		read -p "$1: " question 
	fi
	for ((i = 0; i < ${#valid_answers[@]}; i++))
    do
		if [[ "$question" =~ ^(${valid_answers[$i]})$ ]];
        then 
           	#echo "Valid"
			echo "$question"
        else
			#ask "$1" "${valid_answers[@]}"
			if [ "$3" = "password" ];
			then
				ask "Invalid $3, try with specified password format" "$2" "$3"	
			else
				ask "Invalid $3, try again" "$2" "$3"
			fi
        fi

    done
	

}
export -f ask


# Check if program/service are installed
testCommandResponse(){
# Usage: returns a true if a program or service are located in 
# P1: kommando
# P2: array of valid responses
	valid_response=("$@")
	for ((i = 0; i < ${#valid_response[@]}; i++))
	do
		command_to_test=$($1 | grep -E "${valid_response[$i]}" || echo "")

		# Script will not work with output on
		# echo "command to test $command_to_test"

		if [ -n "$command_to_test" ]; then
			echo "true" 
		fi
	done

}
export -f testCommandResponse


checkGitCredential(){
	value=$(git config --global $1)
	echo "$value"

}
export -f checkGitCredential


checkMariadbPassword(){

	# Is MariaDB installed
	mariadb_installed_array=("mariadb-10.5-server \@10.5.* \(active\)")
	mariadb_installed_specific=$(testCommandResponse "port installed" "$mariadb_installed_array")
	if [ -n "$mariadb_installed_specific" ]; then

		# Is MariaDB running
		mariadb_status_array=("mysql|mariadb")
		mariadb_status=$(testCommandResponse "ps -Aclw" "${mariadb_status_array[@]}")
		if [ "$mariadb_status" = "true" ]; then 

			has_password=$(/opt/local/lib/mariadb-10.5/bin/mysql -u root mysql -e 'SHOW TABLES' 2>&1 | grep "Access denied")
			if [ -n "$has_password" ]; then
				password_is_set="true"
				echo "$password_is_set"
			else 
				password_is_set="false"
				echo "$password_is_set"
			fi

		# Not running
		else

			# Start MariaDB
			command "sudo /opt/local/share/mariadb-10.5/support-files/mysql.server start" "true"

			# Run the function again
			checkMariadbPassword
		fi

	# Not installed
	else 
		password_is_set="false"
		echo "$password_is_set"
	fi

}
export -f checkMariadbPassword


copyFile(){
	file_source=$1 
	file_destination=$2
	cp "$file_source" "$file_destination"
}
export -f copyFile


fileExist(){
	file=$1
	if [ -e "$file" ]; then 
		echo "true"
	else
		echo "false" 
	fi
}
export -f fileExist


trimString(){
	trim=$1
	echo "${trim}" | sed -e 's/^[ \t]*//'
}
export -f trimString


checkFolderExistOrCreate(){
	
	if [ ! -e "$1" ]; then
		echo "Creating folder $1"
		if [ "$2" = "sudo" ]; then
			sudo mkdir $1
		else
			mkdir $1
		fi
	else
		echo "Folder already exist ($1)"
	fi
}
export -f checkFolderExistOrCreate


command(){
	if [[ $2 == true ]]; then
        cmd=$($1 &> /dev/null)
    else
        cmd=$($1)
    fi
    echo "$cmd"
}
export -f command


checkProfile(){

	# ALSO CHECK FOR .profile if it does not exist (contains PATH info)
	# ALSO relevant for multiuser system, where secondary user did not install MacPorts and thus does not have the PATH declaration
	if [ "$(fileExist "/Users/$(getUsername)/.profile")" = "false" ]; then
		outputHandler "comment" "Installing missing .profile with path for Macports"
		sudo cp "/srv/tools/conf/dot_profile" "/Users/$(getUsername)/.profile"
		sudo chown $(getUsername):staff "/Users/$(getUsername)/.profile"
		source "/Users/$(getUsername)/.profile"
	fi

}
export -f checkProfile


checkBashProfile(){

	# ALSO CHECK FOR .profile if it does not exist (contains PATH info)
	# ALSO relevant for multiuser system, where secondary user did not install MacPorts and thus does not have the PATH declaration
	if [ "$(fileExist "/Users/$(getUsername)/.profile")" = "false" ]; then
		outputHandler "comment" "Installing .profile"
		sudo cp "/srv/tools/conf/dot_profile" "/Users/$(getUsername)/.profile"
		sudo chown $(getUsername):staff "/Users/$(getUsername)/.profile"
	fi

	if [ "$(fileExist "/Users/$(getUsername)/.bash_profile")" = "false" ]; then
		outputHandler "comment" "Installing .bash_profile"
		sudo cp "/srv/tools/conf/dot_bash_profile" "/Users/$(getUsername)/.bash_profile"
		sudo chown $(getUsername):staff "/Users/$(getUsername)/.bash_profile"
	fi
}
export -f checkBashProfile


git_prompt () {
	if ! git rev-parse --git-dir > /dev/null 2>&1; then
	  return 0
	fi

	git_branch=$(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p')

	if git diff --quiet 2>/dev/null >&2; then
		git_color=`tput setaf 2`
	else
		git_color=`tput setaf 1`
	fi

	echo " $git_color($git_branch)"
}
export -f git_prompt


check_multiusersystem () {

	echo ""
	echo "Checking WebStack configuration for current user"

	if [ -d /var/parentnode ]; then

		current_user_of_parentnode_folder=$(ls -l /var/ | grep parentnode$ | grep $(getUsername))
		if [ -z "$current_user_of_parentnode_folder" ]; then
			echo "changing"
			sudo chown -R $(getUsername):staff /var/parentnode
		fi

	fi

	current_srv_link_owner=$(ls -l /srv/sites | grep /Users/$(getUsername)/Sites)
	if [ -z "$current_srv_link_owner" ]; then

		sudo unlink /srv/sites
		ln -s ~/Sites /srv/sites

		sudo /opt/local/sbin/apachectl restart

	fi


	echo ""
	echo "System configured correctly"
	echo ""

}
export -f check_multiusersystem
