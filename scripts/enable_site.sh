#!/bin/bash -e

echo "-----------------------------------------------------"
echo ""
echo "                    Enabling site"
echo ""
echo "-----------------------------------------------------"
echo ""


host_file_path="/etc/hosts"
apache_file_path="/srv/sites/apache/apache.conf"


# Request sudo action before continuing to force password prompt (if needed) before script really starts
sudo ls &>/dev/null
echo ""


# Does current location seem to fullfil requirements (is httpd-vhosts.conf found where it is expected to be found)
if [ -e "$PWD/apache/httpd-vhosts.conf" ] ; then

	# Parse DocumentRoot from httpd-vhosts.conf
	document_root=$(grep -E "DocumentRoot" "$PWD/apache/httpd-vhosts.conf" | sed -e "s/	DocumentRoot \"//; s/\"//")

	# Parse ServerName from httpd-vhosts.conf
	server_name=$(grep -E "ServerName" "$PWD/apache/httpd-vhosts.conf" | sed "s/	ServerName //")

	# Parse ServerAlias from httpd-vhosts.conf
	server_alias=$(grep -E "ServerAlias" "$PWD/apache/httpd-vhosts.conf" | sed "s/	ServerAlias //")


	# Seemingly valid config data
	if [ ! -z "$document_root" ] && [ ! -z "$server_name" ]; then

		# Show collected data
		echo "DocumentRoot:	$document_root"
		echo ""
		echo "ServerName: 	$server_name"

		# ServerAlias not always present - only print if it is there
		if [ ! -z "$server_alias" ]; then
			echo "ServerAlias:	$server_alias"
		fi

		echo ""


		# Updating apache.conf

		# Get proper projects path (/srv/sites instead of /Users/username/Sites)
		parentnode_project_path=$(echo "$document_root" | sed -e "s/\\/src\\/www//; s/\\/theme\\/www//")

		# Don't enable sites which are already enabled
		# Check if include path already exists in apache.conf
		apache_entry_exists=$(grep -E "^Include [\"]?$parentnode_project_path\/apache\/httpd-vhosts.conf[\"]?" "$apache_file_path" || echo "")
		if [ -z "$apache_entry_exists" ]; then

			echo "Adding $parentnode_project_path/apache/httpd-vhosts.conf to apache.conf"

			# Include project cont in apache.conf
			echo "Include \"$parentnode_project_path/apache/httpd-vhosts.conf\"" >> "$apache_file_path"
			echo "" >> "$apache_file_path"
		# project already exists in apache.conf
		else

			echo "Project already enabled in $apache_file_path"

		fi


		# Updating hosts

		# Check hosts configuration
		hosts_entry_exists=$(grep -E "[\t ]$server_name" "$host_file_path" || echo "")

		if [ -z "$hosts_entry_exists" ]; then

			echo ""
			echo "Adding $server_name to $host_file_path"

			# Make hosts file writable
			sudo chmod 777 "$host_file_path"

			# Add hosts file entry
			echo "" >> "$host_file_path"
			echo "" >> "$host_file_path"
			echo "127.0.0.1	$server_name" >> "$host_file_path"
			echo "fe80::1%lo0	$server_name" >> "$host_file_path"
			echo "::1			$server_name" >> "$host_file_path"


			# also add ServerAlias'
			if [ ! -z "$server_alias" ]; then

				echo ""

				# Get current IP
				ip=$(ifconfig en0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

				# loop through server alias'
				for domain in $(echo $server_alias | tr " " "\n")
				do
					echo "Adding $domain ($ip) to $host_file_path"
					echo "$ip	$domain" >> "$host_file_path"
				done
				
			fi


			# Set correct hosts file permissions again
			sudo chmod 644 "$host_file_path"

			echo ""


		# Hosts entry already exists for current domain
		else

			echo "Project already enabled in $host_file_path"

		fi

		# Restart apache after modification
		echo ""
		echo "Restating Apache"
		if [ -e "/opt/local/sbin/apachectl" ]; then
			sudo /opt/local/sbin/apachectl restart
		elif [ -e "/opt/local/apache2/apachectl" ]; then
			sudo /opt/local/apache2/apachectl restart
		fi


		echo ""
		echo "Site enabled: OK"
		echo ""


	# Could not find DocumentRoot or ServerName
	else

		echo ""
		echo "Apache configuration seems to be broken."
		echo "Please revert any changes you have made to the https-vhosts.conf file."
		echo ""

	fi

# Could not find httpd-vhosts.conf
else

	echo "Apache configuration not found."
	echo "You can only enable a site, if you run this command from the project root folder"

fi;
