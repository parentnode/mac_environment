#!/bin/bash -e
source /srv/sites/parentnode/mac_environment/scripts/functions.sh

echo ""
echo "ask test"
echo ""
# Standard email format: "david@think.dk"
email_array=("[A-Za-z0-9\.\-]+@[A-Za-z0-9\.\-]+\.[a-z]{2,10}")
email=$(ask "Enter email" "${email_array[@]}" "Email")
# Username can both be an alias name:"superslayer2000", and a normal full name: "Bo Von Niedermeier" and "bo"
username_array=("[A-Za-z0-9[:space:]]{2,50}")
username=$(ask "Enter username" "${username_array[@]}" "Username")
# Password format e.g: testPassword!2000@$
#password_array=("[A-Za-z0-9\!\@\$]{8,30}")
#password1=$( ask "Enter password" "${password_array[@]}" "Password")
#echo ""
#password2=$( ask "Enter password again" "${password_array[@]}" "Password")
#echo ""



password_array=("[A-Za-z0-9\!\@\$]{8,30}")
outputHandler "comment" "For security measures the terminal will not display how many characters you input"
outputHandler "comment" "Password format: between 8 and 30 characters, non casesensitive letters, numbers and  # ! @ \$ special characters "
password1=$(ask "Enter password" "${password_array[@]}" "password")
echo
password2=$(ask "Confirm password" "${password_array[@]}" "password")
echo
# As long the first password input do not match the second password input it will prompt you in a loop to hit the correct keys til it finds a match
if [ "$password1" != "$password2" ]; then
    while [ true ]
    do 
        outputHandler "comment" "Passwords doesn't match"
        password_array=("[A-Za-z0-9\!\@\$]{8,30}")
        password1=$(ask "Enter password anew" "${password_array[@]}" "password")
        echo
        password2=$(ask "Confirm password" "${password_array[@]}" "password")
        echo
        # If there is a match it will break the loop
        if [ "$password1" == "$password2" ]; then
            outputHandler "comment" "Passwords Match"
            break
        fi
        export password1
    done
else
    outputHandler "comment" "Password Match"
    export password1
fi

# While loop if not a match
#if [  "$password1" != "$password2"  ]; then
#    while [ true ]
#    do
#        echo "Password doesn't match"
#        echo
#        #password1=$( ask "Enter mariadb password" "${password_array[@]}" "Password")
#        password1=$( ask "Enter mariadb password" "${password_array[@]}" "Password")
#        echo ""
#        password2=$( ask "Enter mariadb password again" "${password_array[@]}" "Password")
#        echo "" 
#        if [ "$password1" == "$password2" ];
#        then
#            echo "Password Match"
#            break
#        fi
#        echo
#    done
#else
#    echo "Password Match"
#fi
#export password1
echo "$email"
echo "$username"
echo "$password1"