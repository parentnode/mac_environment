#!/bin/bash -e

mariadb_version="mariadb-10"
php_version="php72"


guiText "Installing Software" "Section"

guiText "Pointing Xcode towards the Developer directory instead of Xcode application bundle" "Comment"
#command "sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer/"

guiText "Update macports" "Comment"
#command "sudo port selfupdate"

guiText "Enable getting PID of application really easy" "Comment"
#command "sudo port install pidof"

guiText "MariaDB" "Check"
mariadb_array=("mariadb-10.1" "mariadb-10.2" "mariadb-10.3")
#isInstalled "port installed" "${mariadb_array[@]}"
#is_ok_mariadb=$( isInstalled "port installed" "${mariadb_array[@]}" )
installOrNotToInstall "$(isInstalled "port installed" "${mariadb_array[@]}")" "sudo port -N install mariadb-10.2-server"
#sudo port -N install mariadb-10.2-server # Question: Are we going with 10.2 in mac ?
##testContent "$test_mariadb" "MariaDB" "macports" "$mariadb_version-server"

#guiText "PHP" "Check"
initial_install_array=("php72" "apache2" "mariadb-10.2-server" "pear" "php72-apache2handler")
installOrNotToInstall "$(isInstalled "port installed" "${initial_install_array[@]}")" "sudo port -N install php72 +apache2 +mariadb-10.2-server +pear php72-apache2handler"
#command("sudo port -N install php72 +apache2 +mariadb-server +pear php72-apache2handler");

#test_php=$(isInstalled "port installed $php_version" "$php_version")
#testContent "$test_php" "PHP" "macports" "$php_version"

guiText "Apache" "Check"
#test_apache=$(isInstalled "port installed apache2" "apache" "apache2")
#testContent "$test_apache" "Apache" "macports" "apache2"



#guiText "Installing "