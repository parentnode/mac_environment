#!/bin/bash -e

guiText "Installing Software" "Section"

guiText "Pointing Xcode towards the Developer directory instead of Xcode application bundle" "Comment"
command "sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer/"

guiText "Update macports" "Comment"
command "sudo port selfupdate"

guiText "Enable getting PID of application really easy" "Comment"
command "sudo port install pidof"

guiText "Installing MariaDB" "Comment"
command "sudo port -N install mariadb-10.2-server"
initial_install_array=("php72" "apache2" "mariadb-server" "pear" "php72-apache2handler")
for ((i=0; i < ${#initial_install_array[@]}; i++))
do 
    command "sudo port -N install ${initial_install_array[$i]}"
done
guiText "Installing PHP72-mysql" "Comment"
command "sudo port -N install php72-mysql"
guiText "Installing PHP72-openssl" "Comment"
command "sudo port -N install php72-openssl"
guiText "Installing PHP72-mbstring" "Comment"
command "sudo port -N install php72-mbstring"
guiText "Installing PHP72-curl" "Comment"
command "sudo port -N install php72-curl"
guiText "Installing PHP72-zip" "Comment"
command "sudo port -N install php72-zip"
guiText "Installing PHP72-imagick" "Comment"
command "sudo port -N install php72-imagick"
guiText "Installing PHP72-igbinary" "Comment"
command "sudo port -N install php72-igbinary"
#guiText "Installing PHP72-memcached" "Comment"
##command "sudo port install php72-memcached"
guiText "Installing PHP72-redis" "Comment"
command "sudo port -N install php72-redis"
guiText "Set PHP php72" "Comment" 
command "sudo port select --set php php72"
guiText "Loading redis" "Comment"
command "sudo port load redis"
guiText "Installing ffmpeg" "Comment"
command "sudo port -N install ffmpeg +nonfree"
#autostart apache on boot
guiText "Load apache2" "Comment"
command "sudo port load apache2"
guiText "Software Installed" "Comment"


#guiText "Installing "