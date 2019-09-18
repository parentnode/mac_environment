#!/bin/bash -e

outputHandler "section" "Installing Software"

outputHandler "comment" "Pointing Xcode towards the Developer directory instead of Xcode application bundle"
command "sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer/"

outputHandler "comment" "Update macports"
command "sudo port selfupdate"

outputHandler "comment" "Enable getting PID of application really easy"
command "sudo port install pidof"

outputHandler "comment" "Installing MariaDB"
command "sudo port -N install mariadb-10.2-server"
initial_install_array=("php72" "apache2" "mariadb-server" "pear" "php72-apache2handler")
for ((i=0; i < ${#initial_install_array[@]}; i++))
do 
    command "sudo port -N install ${initial_install_array[$i]}"
done
outputHandler "comment" "Installing PHP72-mysql"
command "sudo port -N install php72-mysql"
outputHandler "comment" "Installing PHP72-openssl"
command "sudo port -N install php72-openssl"
outputHandler "comment" "Installing PHP72-mbstring"
command "sudo port -N install php72-mbstring"
outputHandler "comment" "Installing PHP72-curl"
command "sudo port -N install php72-curl"
outputHandler "comment" "Installing PHP72-zip"
command "sudo port -N install php72-zip"
outputHandler "comment" "Installing PHP72-imagick"
command "sudo port -N install php72-imagick"
outputHandler "comment" "Installing PHP72-igbinary"
command "sudo port -N install php72-igbinary"
#outputHandler "Installing PHP72-memcached"
##command "sudo port install php72-memcached"
outputHandler "comment" "Installing PHP72-redis"
command "sudo port -N install php72-redis"
outputHandler "comment" "Set PHP php72" 
command "sudo port select --set php php72"
outputHandler "comment" "Loading redis"
command "sudo port load redis"
outputHandler "comment" "Installing ffmpeg"
command "sudo port -N install ffmpeg +nonfree"
#autostart apache on boot
outputHandler "comment" "Load apache2"
command "sudo port load apache2"
outputHandler "comment" "Software Installed"

#test placeholder replacing
command "sudo chown $install_user:staff ~/Sites"

#mysql paths
checkFolderExistOrCreate "/opt/local/var/run/mariadb-10.2"
checkFolderExistOrCreate "/opt/local/var/db/mariadb-10.2"
checkFolderExistOrCreate "/opt/local/etc/mariadb-10.2"
checkFolderExistOrCreate "/opt/local/share/mariadb-10.2"


#Mysql preparations
command "sudo chown -R mysql:mysql /opt/local/var/db/mariadb-10.2"
command "sudo chown -R mysql:mysql /opt/local/var/run/mariadb-10.2"
command "sudo chown -R mysql:mysql /opt/local/etc/mariadb-10.2"
command "sudo chown -R mysql:mysql /opt/local/share/mariadb-10.2"

#outputHandler "Installing "