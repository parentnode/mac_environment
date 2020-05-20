#!/usr/bin/php
<?php
include("functions.php");
include("/srv/sites/parentnode/janitor/src/classes/helpers/filesystem.class.php");

$FS = new FileSystem();

// encrypt backup
// openssl enc -aes-256-cbc -d -k $password -in $backup_time.tar.gz.aes -out $backup_time.tar.gz

// To decrypt backup
// openssl enc -aes-256-cbc -k $password -in $backup_time.tar.gz -out $backup_time.tar.gz.aes

// start by requesting sudo power
//enableSuperCow();



// make quick backup to Dropbox or Google Drive

output("Creating quick backup");

$backup_time = date("Ymd_His");
$backup_device = preg_replace("/\.[a-zA-Z]+$/", "", gethostname());

if(file_exists(getAbsolutePath("~/Dropbox/backup"))) {
	$backup_name = getAbsolutePath("~/Dropbox/backup/").$backup_device."/".$backup_time;
}
else if(file_exists(getAbsolutePath("~/Dropbox (Personal)/backup"))) {
	$backup_name = getAbsolutePath("~/Dropbox (Personal)/backup/").$backup_device."/".$backup_time;
}
else if(file_exists(getAbsolutePath("~/Google Drive/backup"))) {
	$backup_name = getAbsolutePath("~/Google Drive/backup/").$backup_device."/".$backup_time;
}
else {
	goodbye("Could not find Dropbox or Google Drive for backup. You should create a folder named 'backup' to enable backup.");
}

$backup_root = dirname($backup_name);
output("Backup location:$backup_name\n");


// Create backup in temp location
$temp_backup = getAbsolutePath("~/temp-backup/$backup_time");
if(!file_exists($temp_backup)) {
	$FS->makeDirRecursively($temp_backup);
}
$temp_backup_root = dirname($temp_backup);


// Applications list
$root_applications = scandir("/Applications");
array_unshift($root_applications, "Root apps:");
$home_applications = scandir(getAbsolutePath("~/Applications"));
array_unshift($home_applications, "Home apps:");
file_put_contents($temp_backup."/Applications.txt", implode("\n", array_merge($root_applications, $home_applications)));
output("Created applications list\n");

// Macports list
$port_output = shell_exec("port installed requested"." 2>&1");
file_put_contents($temp_backup."/Macports.txt", $port_output);
output("Created Macports list\n");



// MySQL
//$output = shell_exec("php ".dirname(realpath($_SERVER["PHP_SELF"]))."/mysql_dump_all.php mysqldump 2>&1");
$output = command("php ".dirname(realpath($_SERVER["PHP_SELF"]))."/mysql_dump_all.php mysqldump", true);
if(preg_match("/Failed/", $output)) {
	goodbye("Failed to connect to MySQL");
}
else {
	output("MySQL data dumped");
	
}
moveFile("~/mysqldump.sql", $temp_backup."/mysqldump.sql");

// config files
copyFile("~/.bash_profile", $temp_backup."/dot_bash_profile");
copyFile("~/.gitconfig", $temp_backup."/dot_gitconfig");
copyFile("~/.gitignore_global", $temp_backup."/dot_gitignore_global");
copyFile("~/.anyconnect", $temp_backup."/dot_anyconnect");
copyFile("~/.tm_properties", $temp_backup."/dot_tm_properties");
copyFile("/etc/hosts", $temp_backup."/hosts");


copyFolder("~/.ssh/", $temp_backup."/dot_ssh");


// copyFolder("~/Sites/apache/", $temp_backup."/Sites/apache/");
$sites_apache_location = getAbsolutePath("~/Sites/apache");
$sites_apache_destination = $temp_backup."/Sites/apache";
$FS->makeDirRecursively($sites_apache_destination);
$sites_apache_files = $FS->files($sites_apache_location);
foreach($sites_apache_files as $sites_apache_file) {

	// Do not copy log files
	if(strpos($sites_apache_file, "/logs") === false) {
		$FS->copy($sites_apache_file, $sites_apache_destination.str_replace($sites_apache_location, "", $sites_apache_file));
	}

}




// copyFolder("~/Desktop/", $backup_name."/Desktop/");

$desktop_location = getAbsolutePath("~/Desktop");
$desktop_destination = $temp_backup."/Desktop";
$FS->makeDirRecursively($desktop_destination);
$desktop_files = $FS->files($desktop_location);
foreach($desktop_files as $desktop_file) {

	if(filesize($desktop_file) < 1000000) {
		$FS->copy($desktop_file, $desktop_destination.str_replace($desktop_location, "", $desktop_file));
	}
}


copyFolder("~/.config/", $temp_backup."/dot_config/");

copyFolder("~/Pictures/", $temp_backup."/Pictures/");

// Frequently contains torrent downloads – SKIP
//copyFolder("~/Documents/", $$temp_backup."/Documents/");

copyFolder("~/Library/Keychains/", $temp_backup."/Library/Keychains/");
copyFolder("~/Library/Preferences/", $temp_backup."/Library/Preferences/");
copyFolder("~/Library/Fonts/", $temp_backup."/Library/Fonts/");

// Use sync for firefox instead
//copyFolder("~/Library/Application Support/Firefox/", $$temp_backup."/Library/Application Support/Firefox");

// Sequel Pro
copyFolder("~/Library/Application Support/Sequel Pro/", $temp_backup."/Library/Application Support/Sequel Pro/");
// SourceTree
//copyFolder("~/Library/Application Support/SourceTree/", $$temp_backup."/Library/Application Support/SourceTree/");
// Fork
copyFolder("~/Library/Application Support/Fork/", $temp_backup."/Library/Application Support/Fork/");
// Textmake
copyFile("~/Library/Application Support/TextMate/Global.tmProperties", $temp_backup."/Library/Application Support/TextMate/Global.tmProperties");
copyFolder("~/Library/Application Support/TextMate/Bundles", $temp_backup."/Library/Application Support/TextMate/Bundles");
copyFolder("~/Library/Application Support/TextMate/Session", $temp_backup."/Library/Application Support/TextMate/Session");
// Cyberduck
// copyFile("~/Library/Group Containers/G69SCX94XU.duck", $backup_name."/Library/Group Containers/G69SCX94XU.duck");


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
		// $file_status = explode(" ", trim($line));
		$file_status = explode(" ", preg_replace("/^[^MADRCU\?]+/", "", $line));

		// print $line."\n";
		// print trim($line)."\n";
		// print ."\n";
		// print_r($file_status);
	
//		print "copying:" . $repos_path."/".$file_status[1].",".$backup_name."/Sites/".str_replace(getAbsolutePath("~/Sites/"), "", $repos_path)."/".$file_status[1]."\n";
		// cannot backup deleted file

		if(count($file_status) > 1) {

			if($file_status[0] !== "D") {
				print "COPY:".$repos_path."/".$file_status[1]."\n";
				copyFile($repos_path."/".$file_status[1], $temp_backup."/Sites/".str_replace(getAbsolutePath("~/Sites/"), "", $repos_path)."/".$file_status[1]);
			}
			// make dummy entry for deleted file
			else {

				$file = $temp_backup."/Sites/".str_replace(getAbsolutePath("~/Sites/"), "", $repos_path)."/".$file_status[1]."-DELETED";
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
	

}


$password = false;
// try to get db password from local config file
$password_file = "~/.mac_environment_backup";
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
	$store_password = ask("Save password in ~/.mac_environment_backup (Y/n)", ["Y", "n"]);

	if($store_password == "Y") {
		$fp = fopen(getAbsolutePath($password_file), "a");
		fwrite($fp, "encryption:".$password."\n");
		fclose($fp);
	}

}

// exit();

// tar.gz backup folder
command("cd '$temp_backup_root' && tar -zcvf $backup_time.tar.gz $backup_time", true, true);

// encrypt it
//print "openssl aes-128-cbc -k $password < $backup_time.tar.gz > $backup_time.tar.gz.aes";
command("cd '$temp_backup_root' && openssl enc -aes-256-cbc -k $password -in $backup_time.tar.gz -out $backup_time.tar.gz.aes", true, true);

// make temp folder deletable (keychain will have some restrictions otherwise)
command("chmod -R 777 '$temp_backup'");
// delete temp folder
command("rm -R '$temp_backup'");
// delete gz-tarball
command("rm -R '$temp_backup.tar.gz'");

// copy encrypted file to backup location
command("mv '$temp_backup.tar.gz.aes' '$backup_name.tar.gz.aes'");

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
			command("rm -R '$backup_root/$backup'");
		}
		$i++;
	}
}
else {
	print "less than 10 backups";
}

// Add cronjob every wednesday at noon
//0 12 * * 3 php /srv/tools/_tools/system_backup.php 

// for testing - runs every 17 min past the hour
//17 * * * * php /srv/tools/_tools/system_backup.php 




?>