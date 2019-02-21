guiText(){
	# Automatic comment format for simple setup as a text based gui
	# eg. guiText "Redis" "Start"
	# $1 Name of object to process
	# $2 Type of process
	case $2 in 
		"Link")
			echo
			echo
			echo "More info regarding $1"
			echo "can be found on $3"
			if [ -n "$4" ];
			then
				echo "and $4"
			fi
			echo
			echo
			;;
		"Comment")
			echo
			echo "$1:"
			if [ -n "$3" ];
			then
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
			echo "$1 allready exists"
			if [ -n "$3" ];
			then
				echo "checking for $3"
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
		echo $(logname) 
	else
		echo $SUDO_USER
	fi
}
export -f getCurrentUser

function isInstalled(){
	if [ "$2" = "Xcode" ] || [ "$2" = "version: " ];then
		check=$($1 | grep "$2" | cut -d \. -f1)
	fi
	if [ "$check" = "$2" + "$3" ];
	then
		echo "$2+$3 installed"
	else 
		if [ -z "$3" ] || [ "$3" < "$check" ];
		then 
			echo "the $2: $3 are not installed use AppStore to install $2"
		fi
	fi
	
}
export -f isInstalled