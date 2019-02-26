guiText(){
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
			echo
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
			echo "Configuring installation for $1"
			if [ -n "$3" ]; then
				echo "in $3"
			fi
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
		"Exit")
			echo "Come back soon we will miss you"
			if [ !$1 = 0 ]; then
				echo "look below for error specified"
				exit $1
			else 
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
	
	if [ "$SUDO_USER" = "root" ];then
		echo "$(logname)" 
	else
		echo $SUDO_USER
	fi
}
export -f getCurrentUser


 
# Newest major release at this time of writing is 10.
function isInstalled(){
	# testing if a version installed by providing 1: command displaying current version. 2 beginning of line we need to search for.
	check=$($1 | grep $2)
	# 3 checking major release number with the version installed.
	if [[ "$check" == *"$3"* ]] && [ -n "$check" ]; then
		guiText "$check" "Installed"
	fi

}
export -f isInstalled

function testContent(){
	if [ -z "$1" ]; then
    	guiText "$2 not installed install $2 with $3" "Comment"
		if [ -n "$4"]; then
			guiText "$2" "Install"
		fi
	else
    	guiText "$1" "Comment"
	fi
} 
export -f testContent

# TODO:
function checkFile(){
	if [ -e "$1" ]; then
		guiText "$1" "Exist"
	else 
		#guiText "$1" "Exist" "$2"
		#guiText "0" "Exit"
		guiText "$1" "Exist" "$1 Exist Not!"
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
		cp $source $destination
	else
		guiText "$destination" "Exist"
	fi	
}
export -f checkFileOrCreate

# TODO:
function checkPath(){
	path=$1
	if [ -f "$path" ]; then
		guiText "$path" "Exist"
	else
		guiText "$path" "Exist" "Creating $path"
		mkdir -p "$path"
	fi
}
export -f checkPath
