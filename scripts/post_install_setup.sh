if [ "$install_webserver_conf" = "Y" ]; then
    echo "Setup Configuration"

    copyFile "/srv/tools/conf/httpd.conf" "/opt/local/etc/apache2/httpd.conf"

    command "sudo chmod 777 /opt/local/etc/apache2/httpd.conf"

    # Update username in file to make apache run as current user (required to access vhosts in dropbox)
    sed -i '' "s/###USERNAME###/$install_user/g" "/opt/local/etc/apache2/httpd.conf"
    command "sudo chmod 644 /opt/local/etc/apache2/httpd.conf"

    copyFile "/srv/tools/conf/httpd-vhosts.conf" "/opt/local/etc/apache2/extra/httpd-vhosts.conf"

    copyFile "/srv/tools/conf/httpd-ssl.conf" "/opt/local/etc/apache2/extra/httpd-ssl.conf"

    if [ $(fileExist "/srv/sites/apache/apache.conf") = "false" ]; then
        copyFile "/srv/tools/conf/apache.conf" "/srv/sites/apache/apache.conf"
        command "sudo chown -R $install_user:staff /Users/$install_user/Sites/apache"
    fi     

    copyFile "/srv/tools/conf/newsyslog-apache.conf" "/etc/newsyslog.d/apache.conf"

    copyFile "/srv/tools/conf/php.ini" "/opt/local/etc/php72/php.ini"
    # Copy php.ini.default for native configuration
    copyFile "/srv/tools/conf/php_ini_native.ini" "/etc/php.ini"

    copyFile "/srv/tools/conf/ssl/star_local.crt" "/srv/sites/apache/ssl/star_local.crt"
    copyFile "/srv/tools/conf/ssl/star_local.key" "/srv/sites/apache/ssl/star_local.key"

    echo "Configuration copied"

    mariadb_installed_array=("mariadb-10.[2-9]-server \@10.[2-9].* \(active\)")
    #mariadb_installed=$(testCommandResponse "port installed mariadb-10.2-server" "$mariadb_installed_array")
    mariadb_installed_specific=$(testCommandResponse "port installed" "$mariadb_installed_array")
    if [ -n "$mariadb_installed_specific" ]; then
        outputHandler "comment" "starting mariadb"
        # Start database
        command "sudo /opt/local/share/mariadb-10.2/support-files/mysql.server start" "true"

        outputHandler "comment" "setting mariadb password"
        if [ "$(checkMariadbPassword)" = "false" ]; then
            command "sudo /opt/local/lib/mariadb-10.2/bin/mysqladmin -u root password "$db_root_password1"" "true"
        else 
            echo "password is sat"
        fi
    fi


    command "sudo /opt/local/sbin/apachectl restart"
fi