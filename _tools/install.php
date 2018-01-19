#!/usr/bin/php
<?php
include("functions.php");


// get current username
$username = getCurrentUser();

// start by requesting sudo power
enableSuperCow();

print get_current_user();

// check software requirements
output("Checking Xcode version");
$is_ok_xcode = isInstalled("xcodebuild -version", array("Xcode 4", "Xcode 5", "Xcode 6", "Xcode 7", "Xcode 8", "Xcode 9"));
output($is_ok_xcode ? "Xcode is OK" : "Xcode check failed - update or install Xcode from AppStore");
if(!$is_ok_xcode) {
	goodbye("Run the setup command again when the command line tools are installed");
}


output("Checking Xcode command line tools version");
$is_ok_xcode_cl = isInstalled("pkgutil --pkg-info=com.apple.pkg.CLTools_Executables", array("version: 6", "version: 7", "version: 8", "version: 9"));
output($is_ok_xcode_cl ? "Xcode command line tools are OK" : "Xcode command line tools check failed - installing now");
if(!$is_ok_xcode_cl) {
	command("xcode-select --install");
	goodbye("Run the setup command again when the command line tools are installed");
}


output("Checking for Macports");
$is_ok_macports = isInstalled("port version", array("Version: 2"));
output($is_ok_macports ? "Macports is OK" : "Macports check failed - update or install Macports from macports.org");

// is software available
if(!$is_ok_macports) {
	goodbye("Update your software as specified above");
}



output("\nChecking paths");

// check if configuration files are available
checkFile("_conf/httpd.conf", "Required file is missing from your configuration source");
checkFile("_conf/httpd-vhosts.conf", "Required file is missing from your configuration source");
checkFile("_conf/php.ini", "Required file is missing from your configuration source");
checkFile("_conf/my.cnf", "Required file is missing from your configuration source");
checkFile("_conf/apache.conf", "Required file is missing from your configuration source");



// TODO: create .bash_profile if it does not exist
// Has not been tested
checkFileOrCreate("~/.bash_profile", "_conf/bash_profile.start");




checkPath("~/Sites");
// set permissions
command("sudo chown $username:staff ~/Sites");

checkPath("/srv");
// only create link if it doesn't exist already (making it twice makes a mess)
if(!file_exists("/srv/sites")) {
	command("sudo ln -s ~/Sites /srv/sites");
}
checkPath("~/Sites/apache");


// continue with setup
output("\nInstalling software");

// make sure correct version of Xcode is selected
command("sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer/");

// update macports
// TODO: enable again when done testing
//command("sudo port selfupdate");

command("sudo port install mariadb-server");
command("sudo port install php72 +apache2 +mariadb-server +pear php72-apache2handler");

command("sudo port install php72-mysql");
command("sudo port install php72-openssl");
command("sudo port install php72-mbstring");
command("sudo port install php72-curl");
command("sudo port install php72-zip");
command("sudo port install php72-imagick");
command("sudo port install php72-memcached");

command("sudo port install git");


// make sure Memcached starts automatically
command("sudo launchctl load -w /Library/LaunchDaemons/org.macports.memcached.plist");

// autostart apache on boot
command("sudo port load apache2");

// test placeholder replacing
command("sudo chown $username:staff ~/Sites");


// mysql paths
checkPath("/opt/local/var/run/mariadb", "sudo");
checkPath("/opt/local/var/db/mariadb", "sudo");
checkPath("/opt/local/etc/mariadb", "sudo");
checkPath("/opt/local/share/mariadb", "sudo");


// Mysql preparations
command("sudo chown -R mysql:mysql /opt/local/var/db/mariadb");
command("sudo chown -R mysql:mysql /opt/local/var/run/mariadb");
command("sudo chown -R mysql:mysql /opt/local/etc/mariadb");
command("sudo chown -R mysql:mysql /opt/local/share/mariadb");



// copy my.cnf for MySQL (to override macports settings)
copyFile("_conf/my.cnf", "/opt/local/etc/mariadb/my.cnf", "sudo");


// see if there is some hint at the database already being installed
$db_response = command("/opt/local/lib/mariadb/bin/mysql -u root mysql -e 'SHOW TABLES'", true);
//$db_response = shell_exec("/opt/local/lib/mariadb/bin/mysql -u root mysql -e 'SHOW TABLES' 2>&1");

// 1049 - UNKNOWN DATABASE - seems like it's not set up yet
// 2002 - NOT RUNNING - seems like it's first run
if(preg_match("/^ERROR (1049|2002)/", $db_response)) {

	output("Installing database");
	command("sudo -u _mysql /opt/local/lib/mariadb/bin/mysql_install_db");
	command("sudo port load mariadb-server");
}
else {
	output("Database already installed - skipping");
}




// install ffmpeg
command("sudo port install ffmpeg +nonfree");

output("\nSoftware installed");


// don't overwrite existing git settings

// update settings
output("\nUpdating GIT settings");

if(!command("git config --global --get core.editor", true)) {
	$answer = ask("GIT text editor  (mate/subl/coda etc.)", array("[a-zA-Z0-9]+"));
	command("git config --global core.editor \"".$answer." -w\"");
}

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

// set permissions
command("sudo chown $username:staff ~/.gitconfig");

output("\nSettings Updated");


// dont clone demo project if it already exists
if(!file_exists("/srv/sites/parentnode/demo_parentnode_dk")) {
	// clone demo site
	output("\nClone demo site");
	command("git clone --recurse-submodules https://github.com/parentnode/demo_parentnode_dk.git /srv/sites/parentnode/demo_parentnode_dk");

	// set permissions
	command("sudo chown -R $username:staff /srv/sites/parentnode");
}
else {
	output("Demo project already exists - skipping");
}


// copy configuration
output("\nCopying configuration");

// copy base configuration
copyFile("_conf/httpd.conf", "/opt/local/etc/apache2/httpd.conf", "sudo");
// set file permissions before trying to update 
command("sudo chmod 777 /opt/local/etc/apache2/httpd.conf");
// update username in file to make apache run as current user (required to access vhosts in dropbox)
replaceInFile("/opt/local/etc/apache2/httpd.conf", "###USERNAME###", $username);
// restore file permissions after update 
command("sudo chmod 644 /opt/local/etc/apache2/httpd.conf");

// copy virtual hosts base configuration
copyFile("_conf/httpd-vhosts.conf", "/opt/local/etc/apache2/extra/httpd-vhosts.conf", "sudo");

// copy base ssl configuration
copyFile("_conf/httpd-ssl.conf", "/opt/local/etc/apache2/extra/httpd-ssl.conf", "sudo");


// create accessible base conf
if(!file_exists("/srv/sites/apache/apache.conf")) {
	copyFile("_conf/apache.conf", "/srv/sites/apache/apache.conf");
	// set permissions
	command("sudo chown -R $username:staff ~/Sites/apache");
}


// copy apache log rotation conf
copyFile("_conf/newsyslog-apache.conf", "/etc/newsyslog.d/apache.conf", "sudo");

// copy php.ini
copyFile("_conf/php.ini", "/opt/local/etc/php72/php.ini", "sudo");

// copy php.ini.default for native configuration
copyFile("_conf/php_ini_native.ini", "/etc/php.ini", "sudo");


// copy wkhtmltox static executables
copyFile("_conf/static_wkhtmltoimage", "/usr/local/bin/static_wkhtmltoimage", "sudo");
copyFile("_conf/static_wkhtmltopdf", "/usr/local/bin/static_wkhtmltopdf", "sudo");


output("\nConfiguration copied");



// Add alias' to .bash_profile
checkFileContent("~/.bash_profile", "_conf/bash_profile.default");
// set correct owner for .bash_profile
command("sudo chown $username:staff ~/.bash_profile");




// Add local domains to /etc/hosts
command("sudo chmod 777 /etc/hosts");
checkFileContent("/etc/hosts", "_conf/hosts.default");
command("sudo chmod 644 /etc/hosts");


// start database
command("sudo /opt/local/share/mariadb/support-files/mysql.server start");

// Set root password
// see if there is some hint at the database already being installed
$db_response = command("/opt/local/lib/mariadb/bin/mysql -u root mysql -e 'SHOW TABLES'", true);
// 1044, 1045 - ACCESS DENIED - seems like password is set
// If not ACCESS DENIED, ask to set root password
if(!preg_match("/^ERROR (1044|1045)/", $db_response)) {

	$answer = ask("MySQL root password", array("[.]{8,30}"), true);
	command("sudo /opt/local/lib/mariadb/bin/mysqladmin -u root password '".$answer."'");
}


// restart apache
command("sudo /opt/local/sbin/apachectl restart");


// DONE
output("\n\nSetup is completed - please restart your terminal");


?>