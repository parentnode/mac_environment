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
	
	
	if [ "$3" = "Password" ]; then
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
			if [ "$3" = "Password" ];
			then
				ask "Invalid $3, try again" "$2" "$3"
				
			else
				ask "Invalid $3, try again" "$2" "$3"
				
			fi
        fi

    done
	

}
export -f ask

# Check if program/service are installed
testCommand(){
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
export -f testCommand

checkGitCredential(){
	value=$(git config user.$1)
	echo "$value"

}
export -f checkGitCredential

checkMariadbPassword(){
	mariadb_installed_array=("(active)")
	mariadb_installed=$(testCommand "port installed mariadb-*-server" "$mariadb_installed_array")
	if [ "$mariadb_installed" = "true" ]; then
		mariadb_status_array=("mysql")
		mariadb_status=$(testCommand "ps -Aclw" "${mariadb_status_array[@]}")
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

function copyFile(){
	file_source=$1 
	file_destination=$2
	cp "$file_source" "$file_destination"
}
export -f copyFile

function fileExist(){
	file=$1
	if [ -f "$file" ]; then 
		echo "true"
	else
		echo "false" 
	fi
}
export -f fileExist

function checkFileContent(){
	query="$1"
	source=$(<$2)
	check_query=$(echo "$source" | grep "$query" || echo "")
	if [ -n "$check_query" ]; then
		echo "true"
	fi 
}
export -f checkFileContent

function syncronizeAlias(){
	input=($(</srv/sites/parentnode/mac_environment))
	#key_array=()
	echo "Alias:"
	#new_value="new text"
	#sed -i '' "s/$old_value/$new_value/g" /srv/sites/parentnode/mac_environment/tests/syncronize_alias_test_files/output

}
export -f syncronizeAlias





function guiText(){
	# Automatic comment format for simple setup as a text based gui
	# eg. guiText "Redis" "Start"
	# $1 Name of object to process
	# $2 Type of process
	case $2 in 
		"Link")
			echo
			echo
			echo "More info regarding $1-webstack installer"
			echo "can be found on https://github.com/parentnode/$1-environment"
			echo "and https://parentnode.dk/blog/installing-the-web-stack-on-mac-os"
			echo
			echo
			;;
		"Comment")
			echo
			echo "$1:"
			if [ -n "$3" ]; then
				echo "$3"
			fi
			;;
		"Section")
			echo
			echo 
			echo "{---$1---}"	
			echo
			echo
			;;
		"Exit")
			echo "Exiting"
			if [ !$1 = 0 ]; then
				echo "Look below for error specified and run steps again"
				exit $1
			else 
				echo "Try again later"
				exit $1
			fi
			;;
		*)
			echo 
			echo "Are you sure you wanted to use gui text here?"
			echo
			;;

	esac
}
export -f guiText


function command(){
	command=$1
	no_echo=$2
	if [ -z "$no_echo" ]; then
		$command
	else
		$command > /dev/null 2>&1
	fi
}
export -f command

function isInstalled(){
	command="$1"
	array=("$@")
	for ((i = 0; i < ${#array[@]}; i++))
	do
		case $command in
			"port installed")
				#echo "using macports to look for ${array[$i]}"
				port_install=$($command | grep "(active)" | sed -n "/${array[$i]}/,/(active)/p")
				#echo "$port_install"
				if [[ "$port_install" =~ "${array[$i]}" ]]; then
					installed="yes"
					export installed
					message="$port_install"
					export message
				fi
				;;
			*)
				check=$($command | grep "${array[$i]}" )
				if [[ "$check" =~ ^${array[$i]}\.[0-9]* ]]; then
					message="$check installed"
					export message
					installed="yes"
					export installed
				fi
				;;

		esac
	done
	if test "$installed" != "yes"; then
		echo "Not Installed"
	else
		echo "$message"
	fi


}
export -f isInstalled

function upgrade(){
	installed=$1
	uninstall_cmd=$2
	install_cmd=$3
	if [ "$installed" = "Not Installed" ]; then
    	echo "$installed"
    	if [ "$3" ]; then
			command "$3"
			#echo "$2"
		fi
		guiText "0" "Exit"
		exit 0 
	else
   		guiText "$installed" "Comment"
		if [ "$2" ];
		then
			guiText "Uninstalling previous version" "Comment"
			command "$2"
		fi
		if [ "$3" ];then
			guiText "Installing an other version" "Comment"
			command "$3"
		fi
	fi

}
export -f upgrade

# TODO:
function checkFile(){
	if [ -e "$1" ]; then
		guiText "$1 exist" "Comment"
	else 
		guiText "$1 does not exist" "Comment"
		guiText "0" "Exit"
	fi
}
export -f checkFile

# TODO:
function checkFileOrCreate(){
	destination=$1
	source=$2

	if [ ! -e "$destination" ]; then
		guiText "$destination does not exist Copying $1" "Comment"
		sudo cp $source $destination
	else
		guiText "$destination exist" "Comment"
	fi	
}
export -f checkFileOrCreate

# TODO:
function checkPath(){
	path=$1
	if [ -d "$path" ]; then
		guiText "$path exist" "Comment"
	else
		guiText "$path does not exist creating $path" "Comment"
		command "$(mkdir -p "$path")"
	fi
}
export -f checkPath

#function copyFile(){
#
#	source=$1
#	destination=$2
#	if [ -f "$source" ]; then
#		sudo cp "$source" $destination
#	#else
#		#copyFolder "$source" "$destination"
#	fi
#
#}
#export -f copyFile

function copyFolder(){

	source=$1
	destination=$2
	if [ -d "$source"]; then

		command "cp -R "$source" "$destination""
	else
		echo "$source not found"
	fi

}
export -f copyFolder

function moveFile(){
	source=$1
	destination=$2
	command "sudo mv "$source" "$destination""

}
export -f moveFile

# Setting Git credentials if needed
gitConfigured(){
	git_credential=$1
	credential_configured=$(git config --global user.$git_credential || echo "")
	if [ -z "$credential_configured" ];
	then 
		echo "No previous git user.$git_credential entered"
		echo
		read -p "Enter your new user.$git_credential: " git_new_value
		git config --global user.$git_credential "$git_new_value"
		echo
	else 
		echo "Git user.$git_credential allready set"
	fi
	echo ""
}
export -f gitConfigured

replaceInFile(){
	file=$1
	old_value=$2
	new_value=$3
	sed -i "s/$old_value/$new_value/g" $1
}
export -f replaceInFile