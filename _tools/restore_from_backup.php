#!/usr/bin/php
<?php
include("functions.php");
include("/srv/sites/parentnode/janitor/src/classes/system/filesystem.class.php");

$FS = new FileSystem();

// encrypt backup
// openssl enc -aes-256-cbc -k $password -in $backup_time.tar.gz -out $backup_time.tar.gz.aes

// To decrypt backup
// openssl enc -aes-256-cbc -d -k $password -in $backup_time.tar.gz.aes -out $backup_time.tar.gz

// start by requesting sudo power
//enableSuperCow();


// make quick backup to Dropbox or Google Drive

output("Restoring from backup");

$backup_time = date("Ymd_His");

if(file_exists(getAbsolutePath("~/Dropbox/backup"))) {
	$backup_name = getAbsolutePath("~/Dropbox/backup/");
}
else if(file_exists(getAbsolutePath("~/Dropbox (Personal)/backup"))) {
	$backup_name = getAbsolutePath("~/Dropbox (Personal)/backup/");
}
else if(file_exists(getAbsolutePath("~/Google Drive/backup"))) {
	$backup_name = getAbsolutePath("~/Google Drive/backup/");
}
else {
	goodbye("Could not find Dropbox or Google Drive for backup. You should create a folder named 'backup' to enable backup.");
}

if(!file_exists($backup_name)) {
	mkdir($backup_name);
}

$backup_root = dirname($backup_name);


output("Backup location:" . $backup_name."\n");


// Applications list
$backups = $FS->files($backup_root);
print_r($backups);
exit();

//foreach($backup_devices = $backup_device)


// Applications list
$root_applications = scandir("/Applications");
array_unshift($root_applications, "Root apps:");
$home_applications = scandir(getAbsolutePath("~/Applications"));
array_unshift($home_applications, "Home apps:");
file_put_contents($backup_name."/Applications.txt", implode("\n", array_merge($root_applications, $home_applications)));
output("Created applications list\n");

// Macports list
$port_output = shell_exec("port installed requested"." 2>&1");
file_put_contents($backup_name."/Macports.txt", $port_output);
output("Created Macports list\n");



// MySQL
command("php ".dirname(realpath($_SERVER["PHP_SELF"]))."/mysql_dump_all.php mysqldump", true, false);
moveFile("~/mysqldump.sql", $backup_name."/mysqldump.sql");

// config files
copyFile("~/.bash_profile", $backup_name."/dot_bash_profile");
copyFile("~/.gitconfig", $backup_name."/dot_gitconfig");
copyFile("~/.gitignore_global", $backup_name."/dot_gitignore_global");
copyFile("~/.tm_properties", $backup_name."/dot_tm_properties");
copyFile("/etc/hosts", $backup_name."/hosts");


copyFolder("~/.ssh/", $backup_name."/dot_ssh");


copyFolder("~/Sites/apache/", $backup_name."/Sites/apache/");
copyFolder("~/Desktop/", $backup_name."/Desktop/");
copyFolder("~/Pictures/", $backup_name."/Pictures/");
copyFolder("~/Documents/", $backup_name."/Documents/");
copyFolder("~/Library/Keychains/", $backup_name."/Library/Keychains/");
copyFolder("~/Library/Preferences/", $backup_name."/Library/Preferences/");
copyFolder("~/Library/Fonts/", $backup_name."/Library/Fonts/");

// Use sync for firefox instead
//copyFolder("~/Library/Application Support/Firefox/", $backup_name."/Library/Application Support/Firefox");
copyFolder("~/Library/Application Support/Sequel Pro/", $backup_name."/Library/Application Support/Sequel Pro/");
copyFolder("~/Library/Application Support/SourceTree/", $backup_name."/Library/Application Support/SourceTree/");
copyFolder("~/Library/Application Support/TextMate/", $backup_name."/Library/Application Support/TextMate/");


// run git status 


// TODO
// - copy any file which has not been comitted
// - push any repos with un-pushed commits
$git_status_output = shell_exec("php ".dirname(realpath($_SERVER["PHP_SELF"]))."/git_status.php"." 2>&1");
$git_status_lines = explode("\n", $git_status_output);
$repos_path = false;

foreach($git_status_lines as $line) {

	// new repos
	if(preg_match("/^Repos: ([^$]+)/", $line, $match)) {

		$repos_path = $match[1];
		// $output = shell_exec("cd ".$repos_path." && git push 2>&1");
		// print "re-output:" . $output . "\n\n";

	}
	else if(!trim($line)) {
		$repos_path = false;
	}
	else if($repos_path && !preg_match("/^No uncomitted files/", $line)) {
		$file_status = explode(" ", trim($line));

//		print "copying:" . $repos_path."/".$file_status[1].",".$backup_name."/Sites/".str_replace(getAbsolutePath("~/Sites/"), "", $repos_path)."/".$file_status[1]."\n";
		// cannot backup deleted file

		if($file_status[0] !== "D") {
			copyFile($repos_path."/".$file_status[1], $backup_name."/Sites/".str_replace(getAbsolutePath("~/Sites/"), "", $repos_path)."/".$file_status[1]);
		}
		// make dummy entry for deleted file
		else {

			$file = $backup_name."/Sites/".str_replace(getAbsolutePath("~/Sites/"), "", $repos_path)."/".$file_status[1]."-DELETED";
			$basedir = dirname($file);

			$path = "/";
			$path_fragments = explode("/", $basedir);
			foreach($path_fragments as $fragment) {
				$path = $path."/".$fragment;
				if(!file_exists("$path")) {
					mkdir("$path");
				}
			}

			touch($file);
		}

	}
	

}


$password = false;
// try to get db password from local config file
$password_file = "~/.os_x_environment_backup";
if(file_exists(getAbsolutePath($password_file))) {


	$config = @file(getAbsolutePath($password_file));
	foreach($config as $line) {
		$values = explode(":", $line);
		if($values[0] == "encryption") {
			$password = trim($values[1]);
		}
	}

}

if($password == false) {
	$password = ask("Encryption password is not stored. Please enter it now", false, true);
	$store_password = ask("Save password in ~/.os_x_environment_backup (Y/n)", ["Y", "n"]);

	if($store_password == "Y") {
		$fp = fopen(getAbsolutePath($password_file), "a");
		fwrite($fp, "encryption:".$password."\n");
		fclose($fp);
	}

}




// tar.gz backup folder
command("cd $backup_root && tar -zcvf $backup_time.tar.gz $backup_time", true, false);

// encrypt it
//print "openssl aes-128-cbc -k $password < $backup_time.tar.gz > $backup_time.tar.gz.aes";
command("cd $backup_root && openssl enc -aes-256-cbc -k $password -in $backup_time.tar.gz -out $backup_time.tar.gz.aes");


// make temp folder deletable (keychain will have some restrictions otherwise)
command("chmod -R 777 $backup_name");
// delete temp folder
command("rm -R $backup_name");
// delete gz-tarball
command("rm -R $backup_name.tar.gz");

// get all backups to see if cleanup is required
$backups = scandir($backup_root);
$backup_index = [];
if(count($backups) > 10) {
	foreach($backups as $backup) {
		if(!preg_match("/^\./", $backup)) {
			$backup_index[preg_replace("/\.[^$]+/", "", $backup)] = $backup;
		}
	}

	krsort($backup_index);

	// Removing old backups
	$i = 0;
	foreach($backup_index as $backup) {
		if($i >= 10) {

			// delete $backup_root/$backup\n;
			command("rm -R $backup_root/$backup");
		}
		$i++;
	}
}
else {
	print "less than 10 backups";
}

// Add cronjob every wednesday at noon
//0 12 * * 3 php /srv/sites/parentnode/os_x_environment/_tools/system_backup.php 

// for testing - runs every 17 min past the hour
//17 * * * * php /srv/sites/parentnode/os_x_environment/_tools/system_backup.php 




?>