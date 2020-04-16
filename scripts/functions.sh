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
			echo
			echo 
			echo "{---$2---}"	
			echo
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
		if [ -n "$command_to_test" ]; then
			echo "true" 
		fi
	done

}
export -f testCommandResponse

checkGitCredential(){
	value=$(git config --global user.$1)
	echo "$value"

}
export -f checkGitCredential

checkMariadbPassword(){
	mariadb_installed_array=("mariadb-10.[2-9]-server \@10.[2-9].* \(active\)")
	#mariadb_installed=$(testCommandResponse "port installed mariadb-10.2-server" "$mariadb_installed_array")
	mariadb_installed_specific=$(testCommandResponse "port installed" "$mariadb_installed_array")
	if [ -n "$mariadb_installed_specific" ]; then
		mariadb_status_array=("mysql")
		mariadb_status=$(testCommandResponse "ps -Aclw" "${mariadb_status_array[@]}")
		if [ "$mariadb_status" = "true" ]; then 
    		has_password=$(/opt/local/lib/mariadb-10.2/bin/mysql -u root mysql -e 'SHOW TABLES' 2>&1 | grep "using password: NO")
			if [ -n "$has_password" ]; then
				password_is_set="true"
				echo "$password_is_set"
			else 
				password_is_set="false"
				echo "$password_is_set"
			fi
		else 
    		echo "mariadb service not running"
			# start service
			echo "Starting mariadb service $(sudo port load mariadb-10.2-server)"
			#running the function again
			checkMariadbPassword
		fi
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

checkFileContent(){
	query="$1"
	source=$(<$2)
	check_query=$(echo "$source" | grep "$query" || echo "")
	if [ -n "$check_query" ]; then
		echo "true"
	fi 
}
export -f checkFileContent

trimString(){
	trim=$1
	echo "${trim}" | sed -e 's/^[ \t]*//'
}
export -f trimString

syncronizeAlias(){
	# Creates backup of default IFS
	OLDIFS=$IFS
	# Set IFS to seperate strings by newline not space
	IFS=$'\n'
	# Source path for testing
	#source="($(</srv/sites/parentnode/mac_environment/tests/syncronize_alias_test_files/source))"
	
	# Source path for script
	source=$(<$2)
	
	# Destination path for testing
	#destination="/srv/sites/parentnode/mac_environment/tests/syncronize_alias_test_files/destination"
	# Destination path for script
	destination=$3
	# Alias line looks like this key: "alias sites" alias sites="cd /srv/sites"
	# Key part of alias line: alias sites  
	key_array=($(echo "$source" | grep "^\"$1" | cut -d \" -f2))	
	# Value part of alias line: alias sites="cd /srv/sites" 
	value_array=($(echo "$source" | grep "^\"$1" | cut -d \" -f3,4,5))
	# Revert to default IFS
	IFS=$OLDIFS
	for ((i = 0; i < "${#key_array[@]}"; i++))
	do
		sed -i '' "s%${key_array[$i]}.*%$(trimString "${value_array[$i]}")%g" $destination
	done
}
export -f syncronizeAlias

deleteAndAppendSection(){
	sed -i '' "/$1/,/$1/d" $3 
    readdata=$( < $2)
    echo "$readdata" | sed -n "/$1/,/$1/p" >> "$3"
}
export -f deleteAndAppendSection

checkFolderExistOrCreate(){
	
	if [ ! -e "$1" ]; then
		echo "Creating folder $1"
		if [ "$2" = "sudo" ]; then
			sudo mkdir $1
		else
			mkdir $1
		fi
	else
		echo "Folder allready exist"
	fi
}
export -f checkFolderExistOrCreate


command(){
	if [[ $2 == true ]]; then
        cmd=$($1 1> /dev/null)
    else
        cmd=$($1)
    fi
    echo "$cmd"
}
export -f command

createOrModifyBashProfile(){
	conf="/srv/tools/conf/dot_profile"
	conf_alias="/srv/tools/conf/dot_profile_alias"
	if [ "$(fileExist "/Users/$install_user/.bash_profile")" = "true" ]; then
		outputHandler "comment" ".bash_profile exists"
		bash_profile_modify_array=("[Yn]")
		bash_profile_modify=$(ask "Do you want to modify existing .bash_profile (Y/n) !this will override existing .bash_profile!" "${bash_profile_modify_array[@]}" "bash_profile_modify")
		export bash_profile_modify
	else
		outputHandler "comment" "Installing .bash_profile"
		copyFile "$conf" "/Users/$install_user/.bash_profile"
	fi
	if [ "$bash_profile_modify" = "Y" ]; then
		does_parentnode_git_exist=$(checkFileContent "# parentnode_git_prompt" "/Users/$install_user/.bash_profile")
		does_parentnode_alias_exist=$(checkFileContent "# parentnode_alias" "/Users/$install_user/.bash_profile")
		does_parentnode_symlink_exist=$(checkFileContent "# parentnode_multi_user" "/Users/$install_user/.bash_profile")
		#if [ "$does_parentnode_git_exist" = "true" ] || [ "$does_parentnode_alias_exist" = "true" ];then 
		#	deleteAndAppendSection "# enable_git_prompt" "/srv/tools/conf/bash_profile_full.default" "/Users/$install_user/.bash_profile"
		#	deleteAndAppendSection "# alias" "/srv/tools/conf/bash_profile_full.default" "/Users/$install_user/.bash_profile"
		#	deleteAndAppendSection "# symlink" "/srv/tools/conf/bash_profile_full.default" "/Users/$install_user/.bash_profile"
		#else
		#	/Users/$install_user/.bash_profile
		#	sudo cp /srv/tools/conf/bash_profile_full.default /Users/$install_user/.bash_profile
		#fi
		if [ "$does_parentnode_git_exist" = "true" ]; then
			deleteAndAppendSection "# parentnode_git_prompt" "$conf" "/Users/$install_user/.bash_profile"
		fi
		if [ "$does_parentnode_alias_exist" = "true" ]; then
			deleteAndAppendSection "# # parentnode_alias" "$conf" "/Users/$install_user/.bash_profile"
		fi
		if [ "$does_parentnode_symlink_exist" = "true" ]; then
			deleteAndAppendSection "# parentnode_multi_user" "$conf" "/Users/$install_user/.bash_profile"
		fi
	else
		syncronizeAlias "alias" "$conf_alias" "$HOME/.bash_profile"
	fi
}
export -f createOrModifyBashProfile

