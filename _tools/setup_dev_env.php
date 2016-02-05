#!/usr/bin/php
<?php
include("functions.php");

// start by requesting sudo power
enableSuperCow();

// check software requirements
output("Checking for Xcode");
$is_ok_xcode = isInstalled("xcodebuild -version", array("Xcode 4", "Xcode 5", "Xcode 6", "Xcode 7"));
output($is_ok_xcode ? "Xcode is OK" : "Xcode check failed - update or install Xcode from AppStore");

output("Checking for Xcode command line tools");
$is_ok_xcode_cl = isInstalled("pkgutil --pkg-info=com.apple.pkg.CLTools_Executables", array("version: 6", "version: 7"));
output($is_ok_xcode_cl ? "Xcode command line tools are OK" : "Xcode command line tools check failed - installing now");
if(!$is_ok_xcode_cl) {
	command("xcode-select --install");
	goodbye("Run the setup command again when the command line tools are installed");
}


output("Checking for Macports");
$is_ok_macports = isInstalled("port version", array("Version: 2"));
output($is_ok_macports ? "Macports is OK" : "Macports check failed - update or install Macports from macports.org");

// is software available
if(!$is_ok_xcode || !$is_ok_macports) {
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
command("sudo mkdir /srv");
command("sudo ln -s ~/Sites /srv/sites");

checkPath("~/Sites/apache");

// mysql paths
checkPath("/opt/local/var/run/mysql56", "sudo");
checkPath("/opt/local/var/db/mysql56", "sudo");
checkPath("/opt/local/etc/mysql56", "sudo");
checkPath("/opt/local/share/mysql56", "sudo");


// continue with setup
output("\nInstalling software");

// make sure correct version of Xcode is selected
command("sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer/");

// update macports
command("sudo port selfupdate");

command("sudo port install mysql56-server");
command("sudo port install php55 +apache2 +mysql56-server +pear php55-apache2handler");

command("sudo port install php55-mysql");
command("sudo port install php55-openssl");
command("sudo port install php55-mbstring");
command("sudo port install php55-curl");
command("sudo port install php55-zip");
command("sudo port install php55-imagick");

command("sudo port install git");


// Mysql preparations
command("sudo chown -R mysql:mysql /opt/local/var/db/mysql56");
command("sudo chown -R mysql:mysql /opt/local/var/run/mysql56");
command("sudo chown -R mysql:mysql /opt/local/etc/mysql56");
command("sudo chown -R mysql:mysql /opt/local/share/mysql56");

// autostart apache on boot
command("sudo port load apache2");


// copy my.cnf for MySQL (to override macports settings)
copyFile("_conf/my.cnf", "/opt/local/etc/mysql56/my.cnf", "sudo");

command("sudo -u _mysql /opt/local/lib/mysql56/bin/mysql_install_db");
command("sudo port load mysql56-server");


// install ffmpeg
command("sudo port install ffmpeg +nonfree");

output("\nSoftware installed");


// update settings
output("\nUpdating settings");

$answer = ask("GIT text editor  (mate/subl/coda etc.)", array("[a-zA-Z0-9]+"));
command("git config --global core.editor \"".$answer." -w\"");

$answer = ask("GIT username", array("[a-zA-Z0-9\-\_]+"));
command("git config --global user.name \"".$answer."\"");

$answer = ask("GIT email", array("[\w\.\-\_]+@[\w-\.]+\.\w{2,4}"));
command("git config --global user.email \"".$answer."\"");

command("git config --global push.default simple");
command("git config --global credential.helper osxkeychain");

output("\nSettings Updated");



// clone demo site
output("\nClone demo site");
command("git clone https://github.com/parentnode/janitor-demo_parentnode_dk.git /srv/sites/parentnode/janitor-demo_parentnode_dk");



// copy configuration
output("\nCopying configuration");

// copy base configuration

copyFile("_conf/httpd.conf", "/opt/local/apache2/conf/httpd.conf", "sudo");
copyFile("_conf/httpd-vhosts.conf", "/opt/local/apache2/conf/extra/httpd-vhosts.conf", "sudo");

// copy apache log rotation conf
copyFile("_conf/newsyslog-apache.conf", "/etc/newsyslog.d/apache.conf", "sudo");

// copy php.ini
copyFile("_conf/php.ini", "/opt/local/etc/php55/php.ini", "sudo");

// create accessible base conf
copyFile("_conf/apache.conf", "/srv/sites/apache/apache.conf");

// copy php.ini.default for native configuration
copyFile("_conf/php_ini_native.ini", "/etc/php.ini", "sudo");



output("\nConfiguration copied");



// Add alias' to .bash_profile
checkFileContent("~/.bash_profile", "_conf/bash_profile.default");


// Set root password
command("sudo /opt/local/share/mysql56/support-files/mysql.server start");
$answer = ask("MySQL root password");
command("sudo /opt/local/lib/mysql56/bin/mysqladmin -u root password '".$answer."'");


output("\n\n ---- \n\nSetup is completed");


// TODO: Cannot set root password until computer has been restarted - Maybe there is another way to make it possible?
// output("\n\nSetup is almost completed - please restart your computer now and run the below command manually in terminal: ");
// output("\n\nsudo /opt/local/lib/mysql56/bin/mysqladmin -u root password '#DB ROOT PASSWORD#'\n\n");

?>