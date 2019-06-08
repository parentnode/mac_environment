<?php

// continue with setup
output("\nInstalling software");

// make sure correct version of Xcode is selected
command("sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer/");

// update macports
//command("sudo port selfupdate");

// enable getting PID of application really easy
command("sudo port install pidof");


// TODO: INCLUDE upgrade script, which checks for versions and uninstall all old stuff 
// and ensure system is ready for install without conflicts


// Remove old mariaDB - MOVE TO UPGRADE SCRIPT
// if(file_exists("/opt/local/var/run/mariadb") && file_exists("/opt/local/lib/mariadb") && file_exists("/opt/local/share/mariadb/support-files/mysql.server")) {
// 	command("sudo /opt/local/share/mariadb/support-files/mysql.server stop");
//
// 	command("sudo port uninstall mariadb-server");
// 	command("sudo port uninstall mariadb");
//
// 	// quit any running instance of mysqld
// 	$pid = command("pidof mysqld");
// 	if($pid) {
// 		command("sudo kill -9 $pid");
// 	}
//
// 	// remove old support folders
// 	command("sudo rm -R /opt/local/var/run/mariadb");
// 	command("sudo rm -R /opt/local/etc/mariadb");
//
// 	// move databases
// 	command("sudo mv /opt/local/var/db/mariadb /opt/local/var/db/mariadb-10.2");
// }


command("sudo port -N install mariadb-10.2-server");
// TODO: on next clean run - test without +mariadeb-server
command("sudo port -N install php72 +apache2 +mariadb-server +pear php72-apache2handler");

command("sudo port -N install php72-mysql");
command("sudo port -N install php72-openssl");
command("sudo port -N install php72-mbstring");
command("sudo port -N install php72-curl");
command("sudo port -N install php72-zip");
command("sudo port -N install php72-imagick");
command("sudo port -N install php72-igbinary");

//command("sudo port install php72-memcached");
command("sudo port -N install php72-redis");

command("sudo port select --set php php72");

command("sudo port -N install redis");
command("sudo port -N install git");
command("sudo port -N install wget");


// make sure Memcached starts automatically
// command("sudo launchctl load -w /Library/LaunchDaemons/org.macports.memcached.plist");

// make sure Redis starts automatically
command("sudo port load redis");

// autostart apache on boot
command("sudo port load apache2");

// test placeholder replacing
command("sudo chown $username:staff ~/Sites");


// mysql paths
checkPath("/opt/local/var/run/mariadb-10.2", "sudo");
checkPath("/opt/local/var/db/mariadb-10.2", "sudo");
checkPath("/opt/local/etc/mariadb-10.2", "sudo");
checkPath("/opt/local/share/mariadb-10.2", "sudo");


// Mysql preparations
command("sudo chown -R mysql:mysql /opt/local/var/db/mariadb-10.2");
command("sudo chown -R mysql:mysql /opt/local/var/run/mariadb-10.2");
command("sudo chown -R mysql:mysql /opt/local/etc/mariadb-10.2");
command("sudo chown -R mysql:mysql /opt/local/share/mariadb-10.2");



// copy my.cnf for MySQL (to override macports settings)
copyFile("conf/my.cnf", "/opt/local/etc/mariadb-10.2/my.cnf", "sudo");


// see if there is some hint at the database already being installed
$db_response = command("/opt/local/lib/mariadb-10.2/bin/mysql -u root mysql -e 'SHOW TABLES'", true);


// 1049 - UNKNOWN DATABASE - seems like it's not set up yet
// 2002 - NOT RUNNING - seems like it's first run
if(preg_match("/^ERROR (1049|2002)/", $db_response)) {

	output("Installing database");
	// if existing mysql db is not found
	if(!file_exists("/opt/local/var/db/mariadb-10.2/mysql")) {
		command("sudo -u _mysql /opt/local/lib/mariadb-10.2/bin/mysql_install_db");
	}
	// enable autostart of mariadb
	command("sudo port load mariadb-10.2-server");
}
else {
	output("Database already installed - skipping");
}




// install ffmpeg
command("sudo port -N install ffmpeg +nonfree");

output("\nSoftware installed");

?>