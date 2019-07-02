#!/bin/bash -e
source /srv/sites/parentnode/mac_environment/scripts/functions.sh

echo ""
echo "ask test"
echo ""
# Standard email format: "david@think.dk"
email_array=("[A-Za-z0-9\.\-]+@[A-Za-z0-9\.\-]+\.[a-z]{2,10}")
email=$(ask "Enter git email" "${email_array[@]}" "Git Email")
# Username can both be an alias name:"superslayer2000", and a normal full name: "Bo Von Niedermeier" and "bo"
username_array=("[A-Za-z0-9[:space:]]{2,50}")
username=$(ask "Enter git username" "${username_array[@]}" "Git Username")
# Password format e.g: testPassword!2000@$
password_array=("[A-Za-z0-9\!\@\$]{8,30}")
password1=$( ask "Enter mariadb password" "${password_array[@]}" "Password")
echo ""
password2=$( ask "Enter mariadb password again" "${password_array[@]}" "Password")
echo ""

# While loop if not a match
if [  "$password1" != "$password2"  ]; then
    while [ true ]
    do
        echo "Password doesn't match"
        echo
        #password1=$( ask "Enter mariadb password" "${password_array[@]}" "Password")
        password1=$( ask "Enter mariadb password" "${password_array[@]}" "Password")
        echo ""
        password2=$( ask "Enter mariadb password again" "${password_array[@]}" "Password")
        echo "" 
        if [ "$password1" == "$password2" ];
        then
            echo "Password Match"
            break
        fi
        echo
    done
else
    echo "Password Match"
fi
export password1
echo "$email"
echo "$username"
echo "$password1"