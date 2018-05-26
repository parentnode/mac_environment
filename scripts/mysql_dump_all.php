#!/usr/bin/php
<?php
include("functions.php");

// start by requesting sudo power
//enableSuperCow();
$password = false;
$store_password = false;

// try to get db password from local config file
$password_file = "~/.mac_environment_backup";
if(file_exists(getAbsolutePath($password_file))) {


	$config = @file(getAbsolutePath($password_file));
	foreach($config as $line) {
		$values = explode(":", $line);
		if($values[0] == "database") {
			$password = trim($values[1]);
		}
	}

}

$host = "127.0.0.1";
$user = "root";
if($password == false) {
	$password = ask("Database root password is not stored. Please enter it now", false, true);
	$store_password = ask("Save password in ~/.mac_environment_backup (Y/n)", ["Y", "n"]);

	if($store_password == "Y") {
		$fp = fopen(getAbsolutePath($password_file), "a");
		fwrite($fp, "database:".$password."\n");
		fclose($fp);
	}

}


$dumpname = (isset($argv[1]) && $argv[1]) ? $argv[1] : (date("Ymd_His_")."allusertables");

// connect to DB
$mysqli = @new mysqli("p:".$host, $user, $password);
if($mysqli->connect_errno) {
    goodbye("Failed to connect to MySQL: " . $mysqli->connect_error);
}

$mysqli->set_charset("utf8");

// get all databases
$select_query = "SHOW databases";
$result = $mysqli->query($select_query);
$result_count = (is_object($result)) ? $result->num_rows : ($result ? $result : 0);

// print $select_query."<br>";
// print "Count: " . $result_count."<br>";


if($result_count) {

	$user_databases = array();
	$results = $result->fetch_all(MYSQLI_ASSOC);

	foreach($results as $database) {
		// only use "non-system" databases
		if(!preg_match("/^(information_schema|mysql|performance_schema|test)$/", $database["Database"])) {
			array_push($user_databases, $database["Database"]); 
		}
			
	}
	
//	print_r($user_databases);

}

if($user_databases) {

	$com = "/opt/local/lib/mariadb-10.2/bin/mysqldump -uroot".($password ? " -p$password" : "")." --databases ".implode($user_databases, " ")." > ~/".$dumpname.".sql | sed -e '$!d'";
	command($com, true);

	output("MySQL dumped into: " . $dumpname . ".sql");
}


?>