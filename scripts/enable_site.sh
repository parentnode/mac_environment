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

getSiteInfo(){
	site_array=("$@")
	if [ -n "${site_array[1]}" ]; then
		if [ "${site_array[0]}" = "${site_array[1]}" ]; then 
			echo "${site_array[0]}"
    	else
			echo "${site_array[@]}"
		fi
	else
		echo "${site_array[0]}"
	fi
}
setHost(){
	server=$(echo -e "127.0.0.1\\t$1")
	
	sudo chmod 777 "$host_file_path"		
	host_exist=$(cat "$host_file_path" | grep "$server" || echo "")
	if [ -z "$host_exist" ]; then 
		echo "Setting up $1 host"
		echo -e "127.0.0.1\\t$1" >> "$host_file_path"
	else 
		echo "$1 exists"	
	fi
	sudo chmod 644 "$host_file_path"
}
enablingApacheSite(){
	include=$(echo "Include \"$(getSiteInfo "$1" | sed s,/theme/www,/apache/httpd-vhosts.conf, )\"")
	apache_entry_exists=$(grep "$include" "$apache_file_path" || echo "")
	#echo "$include"
	#echo "Apache Entry: $apache_entry_exists"
	if [ -z "$apache_entry_exists" ]; then
		echo "enabling conf in $apache_file_path"
		echo "$include" >> "$apache_file_path"
	else
		echo "Virtual Host allready enabled in $apache_file_path"
	fi
}

# Parse DocumentRoot from httpd-vhosts.conf
document_root=($(grep -E "DocumentRoot" "$PWD/apache/httpd-vhosts.conf" | sed -e "s/	DocumentRoot \"//; s/\"//"))
export document_root

# Parse ServerName from httpd-vhosts.conf
server_name=($(grep -E "ServerName" "$PWD/apache/httpd-vhosts.conf" | sed "s/	ServerName //"))
export server_name

# Parse ServerAlias from httpd-vhosts.conf
server_alias=($(grep -E "ServerAlias" "$PWD/apache/httpd-vhosts.conf" | sed "s/	ServerAlias //"))
export server_alias

# Does current location seem to fullfil requirements (is httpd-vhosts.conf found where it is expected to be found)
if [ -e "$PWD/apache/httpd-vhosts.conf" ] ; then

	# Parse DocumentRoot from httpd-vhosts.conf
	document_root=($(grep -E "DocumentRoot" "$PWD/apache/httpd-vhosts.conf" | sed -e "s/	DocumentRoot \"//; s/\"//"))
	export document_root
	
	# Parse ServerName from httpd-vhosts.conf
	server_name=($(grep -E "ServerName" "$PWD/apache/httpd-vhosts.conf" | sed "s/	ServerName //"))
	export server_name
	
	# Parse ServerAlias from httpd-vhosts.conf
	server_alias=($(grep -E "ServerAlias" "$PWD/apache/httpd-vhosts.conf" | sed "s/	ServerAlias //"))
    export server_alias

	# Could not find DocumentRoot or ServerName
    if [ -z "$(getSiteInfo "${document_root[@]}")" ] && [ -z "$(getSiteInfo "${server_name[@]}")" ]; then
		echo ""
		echo "Apache configuration seems to be broken."
		echo "Please revert any changes you have made to the https-vhosts.conf file."
		echo ""
	else
		echo "Setting up site"
		
		for alias in $(getSiteInfo "${server_alias[@]}")
		do
			echo "$alias"
		done
		# Updating apache.conf

		for doc in $(getSiteInfo "${document_root[@]}")
		do
			enablingApacheSite "$doc"
		done
	fi

	# Updating hosts
	for server in $(getSiteInfo "${server_name[@]}")
	do
		setHost "$server"
	done
	
	# Restart apache after modification
	echo ""
	# Restart apache after modification
	echo ""
	echo "Restarting Apache"
	if [ -e "/opt/local/sbin/apachectl" ]; then
		sudo /opt/local/sbin/apachectl restart
	elif [ -e "/opt/local/apache2/apachectl" ]; then
		sudo /opt/local/apache2/apachectl restart
	fi


	echo ""
	echo "Site enabled: OK"
	echo ""
else

	echo "Apache configuration not found."
	echo "You can only enable a site, if you run this command from the project root folder"

fi

## Does current location seem to fullfil requirements (is httpd-vhosts.conf found where it is expected to be found)
#if [ -e "$PWD/apache/httpd-vhosts.conf" ] ; then
#
#	# Parse DocumentRoot from httpd-vhosts.conf
#	document_root=$(grep -E "DocumentRoot" "$PWD/apache/httpd-vhosts.conf" | sed -e "s/	DocumentRoot \"//; s/\"//")
#
#	# Parse ServerName from httpd-vhosts.conf
#	server_name=$(grep -E "ServerName" "$PWD/apache/httpd-vhosts.conf" | sed "s/	ServerName //")
#
#	# Parse ServerAlias from httpd-vhosts.conf
#	server_alias=$(grep -E "ServerAlias" "$PWD/apache/httpd-vhosts.conf" | sed "s/	ServerAlias //")
#
#
#	# Seemingly valid config data
#	if [ ! -z "$document_root" ] && [ ! -z "$server_name" ]; then
#
#		# Show collected data
#
#		# Possibly multible document roots in configuration
#		for line in $document_root; do 
#			echo "DocumentRoot: 	$line"; 
#		done
#		echo ""
#
#		# Possibly multible server names in configuration
#		for line in $server_name; do 
#			echo "ServerName: 	$line"; 
#		done
#
#		# ServerAlias not always present - only print if it is there
#		if [ ! -z "$server_alias" ]; then
#
#			# Possibly multible server alias' in configuration
#			for line in $server_alias; do 
#				echo "ServerAlias: 	$line"; 
#			done
#		fi
#
#
#		echo ""
#
#
#		# Updating apache.conf
#
#		# Possibly multible document roots in configuration
#		for line in $document_root; do 
#
#			# Get proper projects path (/srv/sites instead of /Users/username/Sites)
#			parentnode_project_path=$(echo "$line" | sed -e "s/\\/src\\/www//; s/\\/theme\\/www//")
#
#			# Don't enable sites which are already enabled
#			# Check if include path already exists in apache.conf
#			apache_entry_exists=$(grep -E "^Include [\"]?$parentnode_project_path\/apache\/httpd-vhosts.conf[\"]?" "$apache_file_path" || echo "")
#			if [ -z "$apache_entry_exists" ]; then
#
#				echo "Adding $parentnode_project_path/apache/httpd-vhosts.conf to apache.conf"
#
#				# Include project cont in apache.conf
#				echo "" >> "$apache_file_path"
#				echo "Include \"$parentnode_project_path/apache/httpd-vhosts.conf\"" >> "$apache_file_path"
#			# project already exists in apache.conf
#			else
#
#				echo "$line already enabled in $apache_file_path"
#
#			fi
#
#		done
#
#
#		echo ""
#
#
#		# Updating hosts
#
#
#		# Make hosts file writable
#		sudo chmod 777 "$host_file_path"
#
#		# Possibly multible server names in configuration
#		for line in $server_name; do 
#
#			# Check hosts configuration
#			hosts_entry_exists=$(grep -E "[\t ]$line" "$host_file_path" || echo "")
#
#			if [ -z "$hosts_entry_exists" ]; then
#
#				echo "Adding $line to $host_file_path"
#
#
#				# Add hosts file entry
#				echo "" >> "$host_file_path"
#				echo "" >> "$host_file_path"
#				echo "127.0.0.1	$line" >> "$host_file_path"
#				echo "fe80::1%lo0	$line" >> "$host_file_path"
#				echo "::1			$line" >> "$host_file_path"
#
#
#			# Hosts entry already exists for current domain
#			else
#
#				echo "$line already enabled in $host_file_path"
#
#			fi
#
#		done
#
#		# also add ServerAlias'
#		if [ ! -z "$server_alias" ]; then
#
#			# Get current IP
#			ip=$(ifconfig en0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
#
#			# Possibly multible server alias' in configuration
#			for line in $server_alias; do 
#
#				# Check hosts configuration
#				hosts_entry_exists=$(grep -E "$line" "$host_file_path" || echo "")
#
#				if [ -z "$hosts_entry_exists" ]; then
#
#					# loop through server alias'
#					for domain in $(echo $line | tr " " "\n")
#					do
#						echo "Adding $domain ($ip) to $host_file_path"
#						echo "$ip	$domain" >> "$host_file_path"
#					done
#
#				fi
#
#			done
#		
#		fi
#
#
#		# Set correct hosts file permissions again
#		sudo chmod 644 "$host_file_path"
#
#
#		# Restart apache after modification
#		echo ""
#		echo "Restating Apache"
#		if [ -e "/opt/local/sbin/apachectl" ]; then
#			sudo /opt/local/sbin/apachectl restart
#		elif [ -e "/opt/local/apache2/apachectl" ]; then
#			sudo /opt/local/apache2/apachectl restart
#		fi
#
#
#		echo ""
#		echo "Site enabled: OK"
#		echo ""
#
#
#	# Could not find DocumentRoot or ServerName
#	else
#
#		echo ""
#		echo "Apache configuration seems to be broken."
#		echo "Please revert any changes you have made to the https-vhosts.conf file."
#		echo ""
#
#	fi
#
## Could not find httpd-vhosts.conf
#else
#
#	echo "Apache configuration not found."
#	echo "You can only enable a site, if you run this command from the project root folder"
#
#fi
#