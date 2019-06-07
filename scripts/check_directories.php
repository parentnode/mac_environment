<?php
output("\nChecking paths");

// check if configuration files are available
checkFile("conf/httpd.conf", "Required file is missing from your configuration source");
checkFile("conf/httpd-vhosts.conf", "Required file is missing from your configuration source");
checkFile("conf/php.ini", "Required file is missing from your configuration source");
checkFile("conf/my.cnf", "Required file is missing from your configuration source");
checkFile("conf/apache.conf", "Required file is missing from your configuration source");



// TODO: create .bash_profile if it does not exist
// Has not been tested
checkFileOrCreate("~/.bash_profile", "conf/bash_profile.start");




checkPath("~/Sites");
// set permissions
command("sudo chown $username:staff ~/Sites");

checkPath("/srv");
// only create link if it doesn't exist already (making it twice makes a mess)
if(!file_exists("/srv/sites")) {
	command("sudo ln -s ~/Sites /srv/sites");
}
checkPath("~/Sites/apache");
checkPath("~/Sites/apache/logs");



?>