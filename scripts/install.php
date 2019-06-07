#!/usr/bin/php
<?php
include("functions.php");


// get current username
$username = getCurrentUser();

// start by requesting sudo power
enableSuperCow();

print $username;

output("");

//Pre install checks of software
include("pre_install_check.php");
//checking all directories and files are present 
include("check_directories.php");

//Installing software
include("install_software.php");

exit("End software")


// don't overwrite existing git settings

// update settings
output("\nUpdating GIT settings");

if(!command("git config --global --get user.name", true)) {
	$answer = ask("GIT username", array("[a-zA-Z0-9\-\_]+"));
	command("git config --global user.name \"".$answer."\"");
}

if(!command("git config --global --get user.email", true)) {
	$answer = ask("GIT email", array("[\w\.\-\_]+@[\w-\.]+\.\w{2,4}"));
	command("git config --global user.email \"".$answer."\"");
}

if(!command("git config --global --get push.default", true)) {
	command("git config --global push.default simple");
}
if(!command("git config --global --get credential.helper", true)) {
	command("git config --global credential.helper osxkeychain");
}
if(!command("git config --global --get core.autocrlf", true)) {
	command("git config --global core.autocrlf input");
}


// set permissions
command("sudo chown $username:staff ~/.gitconfig");

output("\nSettings Updated");


// copy configuration
output("\nCopying configuration");

// copy base configuration
copyFile("conf/httpd.conf", "/opt/local/etc/apache2/httpd.conf", "sudo");
// set file permissions before trying to update 
command("sudo chmod 777 /opt/local/etc/apache2/httpd.conf");
// update username in file to make apache run as current user (required to access vhosts in dropbox)
replaceInFile("/opt/local/etc/apache2/httpd.conf", "###USERNAME###", $username);
// restore file permissions after update 
command("sudo chmod 644 /opt/local/etc/apache2/httpd.conf");

// copy virtual hosts base configuration
copyFile("conf/httpd-vhosts.conf", "/opt/local/etc/apache2/extra/httpd-vhosts.conf", "sudo");

// copy base ssl configuration
copyFile("conf/httpd-ssl.conf", "/opt/local/etc/apache2/extra/httpd-ssl.conf", "sudo");


// create accessible base conf
if(!file_exists("/srv/sites/apache/apache.conf")) {
	copyFile("conf/apache.conf", "/srv/sites/apache/apache.conf");
	// set permissions
	command("sudo chown -R $username:staff ~/Sites/apache");
}


// copy apache log rotation conf
copyFile("conf/newsyslog-apache.conf", "/etc/newsyslog.d/apache.conf", "sudo");

// copy php.ini
copyFile("conf/php.ini", "/opt/local/etc/php72/php.ini", "sudo");

// copy php.ini.default for native configuration
copyFile("conf/php_ini_native.ini", "/etc/php.ini", "sudo");


output("\nConfiguration copied");



// Add alias' to .bash_profile
checkFileContent("~/.bash_profile", "conf/bash_profile.default");
// set correct owner for .bash_profile
command("sudo chown $username:staff ~/.bash_profile");




// Add local domains to /etc/hosts
command("sudo chmod 777 /etc/hosts");
checkFileContent("/etc/hosts", "conf/hosts.default");
command("sudo chmod 644 /etc/hosts");


// start database
command("sudo /opt/local/share/mariadb-10.2/support-files/mysql.server start",true);
output("Starting MariaDB");

// Set root password
// see if there is some hint at the database already being installed
$db_response = command("/opt/local/lib/mariadb-10.2/bin/mysql -u root mysql -e 'SHOW TABLES'", true);
// 1044, 1045 - ACCESS DENIED - seems like password is set
// If not ACCESS DENIED, ask to set root password
if(!preg_match("/^ERROR (1044|1045)/", $db_response)) {

	while(true)
	{
		output("");
		$answer = ask("Enter new root password for MariaDB (8-30 chars)", array("(.){8,30}"), true);
		$answer2 = ask("Verify new root password for MariaDB (8-30 chars)", array("(.){8,30}"), true);
		output("");
		if($answer != $answer2)
		{
			output("");
			output("Password need to match");
			output("");
		}
		else
		{
			output("");
			output("Password match");
			output("");
			command("sudo /opt/local/lib/mariadb-10.2/bin/mysqladmin -u root password '".$answer."'", true);
			output("Password set");
			break;
		}
	}
	
}


// restart apache
command("sudo /opt/local/sbin/apachectl restart");


// DONE
output("\n\nSetup is completed - please restart your terminal");


?>