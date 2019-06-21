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
function ask(){
    valid_answers=("$2")
    #cmd_input=$2
	no_echo="$3"
	if [ "$no_echo" = true ]; then
		read -s -p "$1: " question
	else
		read -p "$1: " question
	fi
    
    #if [[ "$question" =~ ^([A-Za-z0-9\.\-]+@[A-Za-z0-9\.\-]+\.[a-z]{2,10})$ ]]; then
    #    echo "valid"
    #else 
    #    echo "non valid"
    #fi
    for ((i = 0; i < ${#valid_answers[@]}; i++))
    do
        if [[ "$question" =~ ^(${valid_answers[$i]})$ ]];
        then 
            echo $question
			echo
        else 
            echo "Not valid "
            ask "$1" "${valid_answers[@]}" "$no_echo"
			echo
        fi
    done

}
export -f ask

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

function copyFile(){

	source=$1
	destination=$2
	if [ -f "$source" ]; then
		sudo cp "$source" $destination
	#else
		#copyFolder "$source" "$destination"
	fi

}
export -f copyFile

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