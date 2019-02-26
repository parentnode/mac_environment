#!/bin/bash -e

mariadb_version="mariadb-10.2"
php_version="php72"


guiText "Installing Software" "Section"

guiText "Pointing Xcode towards the Developer directory instead of Xcode application bundle" "Comment"
#sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer/

guiText "Update macports" "Comment"
#sudo port selfupdate

guiText "Enable getting PID of application really easy" "Comment"
#sudo port install pidof

guiText "Installing MariaDB" "Comment"
test_mariadb=$(isInstalled "port installed $mariadb_version-server" "mariadb" "mariadb-10")
#sudo port -N install mariadb-10.2-server # Question: Are we going with 10.2 in mac ?
testContent "$test_mariadb" "MariaDB" "macports" "$mariadb_version-server"

guiText "Installing PHP" "Comment"
#test_php=$(isInstalled "port installed $php_version" "php" "")


#guiText "Installing "