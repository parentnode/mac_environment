outputHandler "section" "Checking Software Prerequisites are met"

# If you have no need any software you can skip installing by pressing n and then enter
software_valid_answers=("[Yn]")
install_software=$(ask "Install software (Y/n)" "${software_valid_answers[@]}" "install software")
export install_software

if [ "$install_software" = "Y" ]; then
	install_webserver_conf_array=("[Yn]")
	install_webserver_conf=$(ask "Install Webserver Configuration (Y/n)" "${install_webserver_conf_array[@]}" "option webserver conf")
	export install_webserver_conf

	install_ffmpeg_array=("[Yn]")
	install_ffmpeg=$(ask "Install FFMPEG (Y/n)" "${install_ffmpeg_array[@]}" "option ffmpeg")
	export install_ffmpeg

	install_wkhtml_array=("[Yn]")
	install_wkhtml=$(ask "Install WKHTMLTOPDF (Y/n)" "${install_wkhtml_array[@]}" "option wkhtml")
	export install_wkhtml
fi

outputHandler "comment" "Update macports"
# Updates the macports port tree
command "sudo port selfupdate"

outputHandler "section" "Checking for tools required for the installation process"


# SETTING DEFAULT GIT USER
outputHandler "section" "Setting Default GIT USER"
git config --global core.filemode false

# Checks if git credential are allready set, promts for input if not

if [ -z "$(checkGitCredential "name")" ]; then
	git_username_array=("[A-Za-z0-9[:space:]*]{2,50}")
	git_username=$(ask "Enter git username" "${git_username_array[@]}" "gitusername")
	git config --global user.name "$git_username"
else
	git_username="$(checkGitCredential "name")"
	git config --global user.name "$git_username"
fi
if [ -z "$(checkGitCredential "email")" ]; then
	git_email_array=("[A-Za-z0-9\.\-]+@[A-Za-z0-9\.\-]+\.[a-z]{2,10}")
	git_email=$(ask "Enter git email" "${git_email_array[@]}" "gitemail")
	git config --global user.email "$git_email"
else
	git_email="$(checkGitCredential "email")"
	git config --global user.email "$git_email" 
fi
#checkGitCredential "name"
#checkGitCredential "email"

git config --global credential.helper cache
if [ -z $(command "git config --global --get push.default") ]; then 
	command "git config --global push.default simple"
fi

if [ -z $(command "git config --global --get credential.helper") ]; then 
    command "git config --global credential.helper osxkeychain"
fi

if [ -z $(command "git config --global --get core.autocrlf") ]; then
	command "git config --global core.autocrlf input"
fi 

# A function that creates(if none exist) or if you choose Y modifies .bash_profile 
createOrModifyBashProfile
# MYSQL ROOT PASSWORD
#if no mariadb installation found or can login without password checkMariadbPassword returns false 
if [ "$install_webserver_conf" = "Y" ]; then
    if [ "$(checkMariadbPassword)" = "false" ]; then
        password_array=("[A-Za-z0-9\!\@\$]{8,30}")
        outputHandler "comment" "For security measures the terminal will not display how many characters you input"
		outputHandler "comment" "Password format: between 8 and 30 characters, non casesensitive letters, numbers and  # ! @ \$ special characters "
        db_root_password1=$(ask "Enter mariadb password" "${password_array[@]}" "password")
        echo
        db_root_password2=$(ask "Confirm mariadb password" "${password_array[@]}" "password")
        echo
        # As long the first password input do not match the second password input it will prompt you in a loop to hit the correct keys til it finds a match
        if [ "$db_root_password1" != "$db_root_password2" ]; then
            while [ true ]
            do 
                outputHandler "comment" "Passwords doesn't match"
                password_array=("[A-Za-z0-9\!\@\$]{8,30}")
                db_root_password1=$(ask "Enter mariadb password anew" "${password_array[@]}" "password")
                echo
                db_root_password2=$(ask "Confirm mariadb password" "${password_array[@]}" "password")
                echo
                # If there is a match it will break the loop
                if [ "$db_root_password1" == "$db_root_password2" ]; then
                    outputHandler "comment" "Passwords Match"
                    break
                fi
                export db_root_password1
            done
        else
            outputHandler "comment" "Password Match"
            export db_root_password1
        fi
    else
        outputHandler "comment" "Mariadb password allready set up"
    fi
fi
# Change localuser group of .gitconfig to staff 
command "sudo chown $install_user:staff /Users/$install_user/.gitconfig"

# Array containing major releases of Xcode
outputHandler "comment" "Checking for xcode"
xcode_array=( "Xcode 4" "Xcode 5" "Xcode 6" "Xcode 7" "Xcode 8" "Xcode 9" "Xcode 10" "Xcode 11" )
if [ $(testCommand "xcodebuild -version" "${xcode_array[@]}") = "true" ]; then
    outputHandler  "comment" "Xcode installed "
else
    outputHandler "exit" "Install Xcode with app store and try again"
fi

outputHandler "comment" "Checking for Xcode command line tools version"
xcode_array_cl=( "version: 6" "version: 7" "version: 8" "version: 9" "version: 10" "version: 11" )
if [ $(testCommand "pkgutil --pkg-info=com.apple.pkg.CLTools_Executables" "${xcode_array_cl[@]}") = "true" ]; then 
    outputHandler "comment" "Xcode Command Line tools installed"
else
    outputHandler "exit" "Install Xcode Command Line tools with app store and try again"
fi


outputHandler "comment" "Checking for Macports"
macports_array=("Version: 2")

if [ $(testCommand "port version" "${macports_array[@]}") = "true" ]; then
    outputHandler "comment" "Macports installed"
else
    outputHandler "exit" "Update macports and try again"
fi

exit