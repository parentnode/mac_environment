#!/usr/bin/php
<?php
include("functions.php");

// start by requesting sudo power
enableSuperCow();


$db_janitor_db = false;
$db_janitor_user = false;
$db_janitor_pass = false;


// find local config file
if(file_exists("src/config/connect_db.php")) {

	$connection_info = file_get_contents("src/config/connect_db.php");

	preg_match("/\"SITE_DB\", \"([a-zA-Z0-9\.\-\_]+)\"/", $connection_info, $matches);
	if($matches) {
		$db_janitor_db = $matches[1];
	}

	preg_match("/\"username\" \=\> \"([a-zA-Z0-9\.\-]+)\"/", $connection_info, $matches);
	if($matches) {
		$db_janitor_user = $matches[1];
	}

//	preg_match("/\"password\" \=\> \"([a-zA-Z0-9\.\-]+)\"/", $connection_info, $matches);
	preg_match("/\"password\" \=\> \"([^\"]+)\"/", $connection_info, $matches);
	if($matches) {
		$db_janitor_pass = $matches[1];
	}

}

if(!$db_janitor_db || !$db_janitor_user || !$db_janitor_pass) {

	print "This script is supposed to be run in project root. It could not find grant information in src/config/connect_db.php";
	exit();
	
}

$host = "localhost";
$user = "root";
$pass = ask("Database root password", false, true);

// connect to DB
$mysqli = new mysqli("p:".$host, $user, $pass);
if($mysqli->connect_errno) {
    echo "Failed to connect to MySQL: " . $mysqli->connect_error;
}
$mysqli->set_charset("utf8");

// get all databases
$select_query = "GRANT ALL PRIVILEGES ON ".$db_janitor_db.".* TO '".$db_janitor_user."'@'localhost' IDENTIFIED BY '".$db_janitor_pass."' WITH GRANT OPTION;";
$result = $mysqli->query($select_query);
$result_count = (is_object($result)) ? $result->num_rows : ($result ? $result : 0);

// print $select_query."<br>";
// print "Count: " . $result_count."<br>";


if($result_count) {
	print "\nGrant added!\n\n";
}
else {
	print "\nGrant failed!\n\n";
}


?>