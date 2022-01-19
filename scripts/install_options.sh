#!/bin/bash

outputHandler "section" "Choose what to install"


# Software
software_valid_answers=("[Yn]")
install_software=$(ask "Install software (Y/n)" "${software_valid_answers[@]}" "option for software")
export install_software

# Webserver configuration
install_configuration_answers=("[Yn]")
install_configuration=$(ask "Install webstack configuration (Y/n)" "${install_configuration_answers[@]}" "option for webstack configuration")
export install_configuration

# FFmpeg
install_ffmpeg_answers=("[Yn]")
install_ffmpeg=$(ask "Install FFmpeg (Y/n)" "${install_ffmpeg_answers[@]}" "option for FFmpeg")
export install_ffmpeg

# WKHTML
install_wkhtml_answers=("[Yn]")
install_wkhtml=$(ask "Install wkhtmltopdf (Y/n)" "${install_wkhtml_answers[@]}" "option for wkhtmltopdf")
export install_wkhtml



# MariaDB root password
if [ "$install_configuration" = "Y" ]; then

	# MYSQL ROOT PASSWORD
	# Only ask if no mariadb installation found
	# or if we can login without password
	if [ "$(checkMariadbPassword)" = "false" ]; then
		password_array=("[A-Za-z0-9\!\@\$]{8,30}")

		outputHandler "comment" "To secure your MariaDB you must create a root password." "For security measures the terminal will not display how many characters you input" "Password format: between 8 and 30 characters, non casesensitive letters, numbers and  #!@\$ special characters."

		db_root_password1=$(ask "Enter MariaDB root password" "${password_array[@]}" "password")
		echo

		db_root_password2=$(ask "Confirm MariaDB password" "${password_array[@]}" "password")
		echo

		# As long the first password input do not match the second password input it will prompt you in a loop to hit the correct keys until it finds a match
		if [ "$db_root_password1" != "$db_root_password2" ]; then
			while [ true ]
			do 
				outputHandler "comment" "Passwords doesn't match – please try again"

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

				set_db_root_password="true"
				export set_db_root_password
			done
		else

			outputHandler "comment" "Password Match"
			export db_root_password1

			set_db_root_password="true"
			export set_db_root_password

		fi

	else

		set_db_root_password="false"
		export set_db_root_password

	fi

fi


outputHandler "comment" "Options: OK"
