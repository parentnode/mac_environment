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

// don't overwrite existing git settings

// update settings
include("configuration.php");

exit("End configuration");
// restart apache
command("sudo /opt/local/sbin/apachectl restart");


// DONE
output("\n\nSetup is completed - please restart your terminal");


?>