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
			if [ "$1" = "mac" ]; then
				echo "and https://parentnode.dk/blog/installing-the-web-stack-on-mac-os"
			fi
			if [ "$1" = "windows" ]; then
				echo "and https://parentnode.dk/blog/installing-web-stack-on-windows-10"
			fi
			if [ "$3" = "ubuntu-client" ]; then
				echo "and https://parentnode.dk/blog/installing-the-web-stack-on-ubuntu"
			fi
			if [ "$3" = "ubuntu-server" ]; then
				echo "and https://parentnode.dk/blog/setup-ubuntu-linux-production-server-and-install-the-parentn"
			fi
			
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
		#These following commentary cases are used for installing and configuring setup
		"Start")
			echo
			echo
			echo "Starting installation process for $1"
			echo
			echo
			;;
		"Download")
			echo
			echo "Downloading files for the installation of $1"
			echo "This could take some time depending on your internet connection"
			echo "and hardware configuration"
			echo
			echo
			;;
		"Exist")
			echo
			if [ -n "$3" ]; then
				echo "$1 Does not exist "
				echo "$3"
			else
				echo "$1 exists"
			fi
			echo ""
			if [ -n "$4" ];
			then
				echo "checking for $4"
			fi
			echo
			echo
			;;
		"Install")
			echo
			echo "Install $1"
			if [ -n "$3" ]; then
				echo "with $3"
			fi
			echo "Then run script again"
			echo
			;;
		"Replace")
			echo
			echo "Replacing $1 with $3"
			echo
			;;
		"Installed")
			echo
			echo "$1 Installed no need for more action at this point"
			echo
			;;
		"Enable")
			echo
			echo "Enabling $1"
			echo
			;;
		"Disable")
			echo
			echo "Disabling $2"
			echo
			;;
		"Done")
			echo
			echo
			echo "Installation process for $1 are done"
			echo
			echo
			;;
		"Skip")
			echo
			echo
			echo "Skipping Installation process for $1"
			echo
			echo
			;;
		"Check")
			echo
			echo
			echo "Checking if $1 are installed"
			if [ -n "$3" ]; then 
				echo "$3"
			fi
			echo 
			;;
		"Ok")
			echo
			echo "$1: OK"
			echo
			;;
		"Exit")
			echo "Exiting"
			exit_message="Run script again when installed"
			if [ !$1 = 0 ]; then
				echo "look below for error specified"
				echo "$exit_message"
				exit $1
			else 
				echo "$exit_message"
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

# Get the username of current user by looking at the folder name of the current user directory
# because the current script will typically run as root (sudo)

function getCurrentUser() {
	
	#if [ "$SUDO_USER" = "root" ];then
	#	echo "$(logname)" 
	#else
	#	echo $SUDO_USER
	#fi
	user=$(whoami)
	echo "$user"
}
export -f getCurrentUser

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
   		guiText "$installed" "Exist"
		if [ "$2" ];
		then
			guiText "Uninstalling previous version" "Comment"
			command "$2"
		fi
		if [ "$3" ];then
			guiText "Installing a nother version" "Comment"
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
		guiText "$1" "Exist"
	else 
		guiText "$1" "Exist" "$2"
		guiText "0" "Exit"
		#echo "Not existing"
	fi
	#filename $1
	#message $2
}
export -f checkFile

# TODO:
function checkFileOrCreate(){
	destination=$1
	source=$2

	if [ ! -e "$destination" ]; then
		guiText "$destination" "Exist" "Copying $1"
		sudo cp $source $destination
	else
		guiText "$destination" "Exist"
	fi	
}
export -f checkFileOrCreate

# TODO:
function checkPath(){
	path=$1
	if [ -d "$path" ]; then
		guiText "$path" "Exist"
	else
		guiText "$path" "Exist" "Creating $path"
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