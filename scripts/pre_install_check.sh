guiText "Checking for tools required for the installation process" "Section"

guiText "Checking for existing mariadb setup" "Section"
# MYSQL ROOT PASSWORD

#db_response=$(command "("/opt/local/lib/mariadb-10.2/bin/mysql -u root mysql -e 'SHOW TABLES'")" "false")
#echo "$test_password"
allowed_mariadb_server=("mariadb-10.2-server")
mariadb_check=$(isInstalled "port installed" "${allowed_mariadb_server[@]}")

if [ "$mariadb_check" = "Not Installed" ]; then
    echo "$mariadb_check"
    echo 
    echo "Installer will continue and install mariadb"
else
    root_password_status=$(/opt/local/lib/mariadb-10.2/bin/mysql -u root mysql -e 'SHOW TABLES' 2>&1)
    #root_password_status=$(/opt/local/lib/mariadb-10.2/bin/mysql -u root mysql -e 'SHOW TABLES' &> $test)
    test_password=$(echo "$root_password_status" | grep "using password: NO" || echo "")
    echo "test $root_password_status"
    exit 0
    if [ -z "$test_password" ];
    then 
        while [ "$test_password" ]
        do
            valid_password=("[A-Za-z0-9 \! \@ \— ]{8,30}")
            maria_db_password=$(ask "Enter password" "${valid_password[@]}" "true" )
            echo
            verify_maria_db_password=$(ask "Verify password" "${valid_password[@]}" "true")
            echo
            if [ "$maria_db_password" != "$verify_maria_db_password" ]; then
                echo "Password do not match"
                echo "Try again"
                echo
            else
                echo "Password match"
                command "sudo /opt/local/lib/mariadb-10.2/bin/mysqladmin -u root password '"$maria_db_password"'" 
            fi
        done
    else
        echo "Password previously set"
    fi
fi


# SETTING DEFAULT GIT USER
guiText "Setting Default GIT USER" "Section"
git config --global core.filemode false
#git config --global user.name "$install_user"
#git config --global user.email "$install_email"

# Checks if git credential are allready set, promts for input if not
gitConfigured "name"
gitConfigured "email"

git config --global credential.helper cache
command "sudo chown $install_user:staff /Users/$install_user/.gitconfig"

# Array containing major releases of Xcode

guiText "Checking for xcode" "Comment"
xcode_array=( "Xcode 4" "Xcode 5" "Xcode 6" "Xcode 7" "Xcode 8" "Xcode 9" "Xcode 10" )
upgrade "$( isInstalled "xcodebuild -version" "${xcode_array[@]}" )"


guiText "Checking for Xcode command line tools version" "Comment"
xcode_array_cl=( "version: 6" "version: 7" "version: 8" "version: 9" "version: 10" )
upgrade "$(isInstalled "pkgutil --pkg-info=com.apple.pkg.CLTools_Executables" "${xcode_array_cl[@]}")" "" "xcode-select --install"


guiText "Checking for Macports" "Comment"
macports_array=("Version: 2")
upgrade "$(isInstalled "port version" "${macports_array[@]}")"

