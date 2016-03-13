#!/usr/bin/php
<?php
include("functions.php");

// start by requesting sudo power
enableSuperCow();

$host = "localhost";
$user = "root";
$pass = ask("Database root password", false, true);

$dumpname = (isset($argv[1]) && $argv[1]) ? $argv[1] : (date("Ymd_His_")."allusertables");

// connect to DB
$mysqli = @new mysqli("p:".$host, $user, $pass);
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

	command("sudo /opt/local/lib/mysql56/bin/mysqldump -uroot -p$pass --databases ".implode($user_databases, " ")." > ".$dumpname.".sql | sed -e '$!d'", true);

	output("MySQL dumped into: " . $dumpname . ".sql");
}


?>