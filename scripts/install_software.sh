#!/bin/bash -e

guiText "Installing Software" "Section"

guiText "Pointing Xcode towards the Developer directory instead of Xcode application bundle" "Comment"
#sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer/

guiText "Update macports" "Comment"
#sudo port selfupdate

guiText "Enable getting PID of application really easy" "Comment"
#sudo port install pidof

guiText "Installing MariaDB" "Comment"
test_mariadb=$(isInstalled "type -a mysql" ^"mariadb" "mariadb")
testContent "$test_mariadb" "MariaDB" "macports"
#sudo port -N install mariadb-10.2-server # Question: Are we going with 10.2 in mac ?

#guiText "Installing "