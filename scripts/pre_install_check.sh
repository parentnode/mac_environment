
valid_answers=("[Y n]")
install_software=$(ask "Install software (Y/n)" "${valid_answers[@]}" "install_software")
export install_software

createOrModifyBashProfile

outputHandler "section" "Checking for tools required for the installation process"
outputHandler "section" "Checking for existing mariadb setup"
# MYSQL ROOT PASSWORD
if [ "$(checkMariadbPassword)" = "false" ]; then
    password_array=("[A-Za-z0-9\!\@\$]{8,30}")
    db_root_password1=$(ask "Enter mariadb password" "${password_array[@]}" "password")
    echo
    db_root_password2=$(ask "Verify mariadb password" "${password_array[@]}" "password")
    echo
    if [ "$db_root_password1" != "$db_root_password2" ]; then
        while [ true ]
        do 
            echo "Passwords doesn't match"
            echo
            password_array=("[A-Za-z0-9\!\@\$]{8,30}")
            db_root_password1=$(ask "Enter mariadb password" "${password_array[@]}" "password")
            echo
            db_root_password2=$(ask "Verify mariadb password" "${password_array[@]}" "password")
            echo
            if [ "$db_root_password1" == "$db_root_password2" ]; then
                echo "Passwords Match"
                break
            fi
            export db_root_password1
        done
    else
        echo "Password Match"
        export db_root_password1
    fi
else
    outputHandler "comment" "Mariadb password allready set up"
fi

#db_response=$(command "("/opt/local/lib/mariadb-10.2/bin/mysql -u root mysql -e 'SHOW TABLES'")" "false")
#echo "$test_password"
#allowed_mariadb_server=("mariadb-10.2-server")

#mariadb_check=$(testCommand "port installed" "${allowed_mariadb_server[@]}")
#echo "$mariadb_check"
#exit 0
#if [[ "$mariadb_check" != "true" ]]; then
#    echo "$mariadb_check"
#    echo 
#    echo "Mariadb not installed"
#else
#    root_password_status=$(/opt/local/lib/mariadb-10.2/bin/mysql -u root mysql -e 'SHOW TABLES' 2>&1)
#    test_password=$(echo "$root_password_status" | grep -o "using password: YES" || echo "")
#    if [ -z "$test_password" ]; then
#        echo "$test_password"
#    fi
#    if [ -z "$test_password" ];
#    then 
#        while [ "$test_password" ]
#        do
#            valid_password=("[A-Za-z0-9 \! \@ \— ]{8,30}")
#            maria_db_password=$(ask "Enter password" "${valid_password[@]}" "password" )
#            echo
#            verify_maria_db_password=$(ask "Verify password" "${valid_password[@]}" "password")
#            echo
#            if [ "$maria_db_password" != "$verify_maria_db_password" ]; then
#                echo "Password do not match"
#                echo "Try again"
#                echo
#            else
#                echo "Password match"
#                command "sudo /opt/local/lib/mariadb-10.2/bin/mysqladmin -u root password '"$maria_db_password"'" 
#            fi
#        done
#    else
#        echo "Password previously set"
#    fi
#fi


# SETTING DEFAULT GIT USER
guiText "Setting Default GIT USER" "Section"
git config --global core.filemode false
#git config --global user.name "$install_user"
#git config --global user.email "$install_email"

# Checks if git credential are allready set, promts for input if not
gitConfigured "name"
gitConfigured "email"

git config --global credential.helper cache
if [ -z $(command "git config --global --get push.default") ]; then 
	command "git config --global push.default simple"
fi

#if [ -z $(command "git config --global --get credential.helper") ]; then 
#    command "git config --global credential.helper osxkeychain"
#fi

if [ -z $(command "git config --global --get core.autocrlf") ]; then
	command "git config --global core.autocrlf input"
fi
command "sudo chown $install_user:staff /Users/$install_user/.gitconfig"

# Array containing major releases of Xcode

outputHandler "comment" "Checking for xcode"
xcode_array=( "Xcode 4" "Xcode 5" "Xcode 6" "Xcode 7" "Xcode 8" "Xcode 9" "Xcode 10" )
#testCommand "xcodebuild -version" "${xcode_array[@]}"
if [ $(testCommand "xcodebuild -version" "${xcode_array[@]}") = "true" ]; then
    outputHandler "Xcode installed "
else
    outputHandler "exit" "Install Xcode with app store and try again"
fi

outputHandler "comment" "Checking for Xcode command line tools version"
xcode_array_cl=( "version: 6" "version: 7" "version: 8" "version: 9" "version: 10" )
#upgrade "$(isInstalled "pkgutil --pkg-info=com.apple.pkg.CLTools_Executables" "${xcode_array_cl[@]}")" "" "xcode-select --install"
if [ $(testCommand "pkgutil --pkg-info=com.apple.pkg.CLTools_Executables" "${xcode_array_cl[@]}") = "true" ]; then 
    outputHandler "comment" "Xcode Command Line tools installed"
else
    outputHandler "exit" "Install Xcode Command Line tools with app store and try again"
fi


outputHandler "comment" "Checking for Macports"
macports_array=("Version: 2")

#upgrade "$(isInstalled "port version" "${macports_array[@]}")"
#if [ $(testCommand "port version" "${macports_array[@]}") = "true" ]; then
#    outputHandler "comment" "Macports installed"
#else
#    outputHandler "exit" "Update macports and try again"
#fi

