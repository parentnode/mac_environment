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
	$backup_root = getAbsolutePath("~/Dropbox/backup");
}
else if(file_exists(getAbsolutePath("~/Dropbox (Personal)/backup"))) {
	$backup_root = getAbsolutePath("~/Dropbox (Personal)/backup");
}
else if(file_exists(getAbsolutePath("~/Google Drive/backup"))) {
	$backup_root = getAbsolutePath("~/Google Drive/backup");
}
else {
	goodbye("Could not find Dropbox or Google Drive for backup. You should create a folder named 'backup' to enable backup.");
}


output("Backup location:" . $backup_root."\n");

$backup_devices = [];

// Index available backups
$backups_files = $FS->files($backup_root, ["allow_extensions" => "aes"]);
foreach($backups_files as $backup) {
	$backup_fragments = explode("/", str_replace($backup_root."/", "", $backup));

	// seems like a valid backup
	if(count($backup_fragments) > 1) {
		$backup_device_files[$backup_fragments[0]][] = $backup_fragments[1];

		// separate list of backups
		if(array_search($backup_fragments[0], $backup_devices) === false) {
			$backup_devices[] = $backup_fragments[0];
		}
	}
}


output("Backups available from these devices:\n");

// loop through backup devices
foreach($backup_devices as $i => $backup_device) {

	$device_index = ($i+1);
	output($device_index." :" .$backup_device);

	$valid_options[] = $device_index;

}
// ask user to select device
$selected_device = ask("\nSelect device", $valid_options);


// clear valid options
$valid_options = [];

if(count($backup_devices) < $selected_device) {
	goodbye("Unknown device");
}
else {

	$backup_device = $backup_devices[$selected_device-1];
	output("\nBackups available from ".$backup_device.":\n");

	foreach($backup_device_files[$backup_device] as $i => $backup) {
		$backup_index = ($i+1);
		preg_match("/(\d\d\d\d)(\d\d)(\d\d)_(\d\d)(\d\d)(\d\d)/", $backup, $ts);
		output($backup_index.": ".($backup_index < 10 ? " " : "").$ts[1]. "/".$ts[2]. "/".$ts[3]. " ". $ts[4].":".$ts[5]. " (".$backup.")".($i == 0 ? " - LATEST" : ""));

		$valid_options[] = $backup_index;

	}

	// ask user to select backup
	$selected_backup = ask("\nSelect backup", $valid_options);
}


if(!isset($backup_device_files[$backup_device]) || !isset($backup_device_files[$selected_device][$selected_backup-1])) {
	
	$backup = $backup_device_files[$backup_device][$selected_backup-1];
//	$backup_file = $backup_root."/".$backup_device."/".$backup;

	if(file_exists($backup_root."/".$backup_device."/".$backup) && preg_match("/\.tar\.gz\.aes$/", $backup)) {

		$backup_file_name = preg_replace("/\.tar\.gz\.aes$/", "", $backup);
		
		output("\nRestoring from:" .$backup_device."/".$backup);


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

		$backup_folder = "";

		// copy backup file to user home dir (unpacking and deleting fast in Dropbox makes it freak out)
		copyFile("$backup_root/$backup_device/$backup_file_name.tar.gz.aes", "~/");

		// encrypt it
		//print "openssl aes-128-cbc -k $password < $backup_time.tar.gz > $backup_time.tar.gz.aes";
		command("cd ~/ && openssl enc -aes-256-cbc -d -k $password -in '$backup_file_name.tar.gz.aes' -out '$backup_file_name.tar.gz'", true, true);

		// tar.gz backup folder
		command("cd ~/ && tar -zxvf '$backup_file_name.tar.gz'", true, true);

		$backup_folder = getAbsolutePath("~/$backup_file_name");
		if($backup_folder) {

			command("rm -R '".getAbsolutePath("~/$backup_file_name.tar.gz")."'", true, true);
			command("rm -R '".getAbsolutePath("~/$backup_file_name.tar.gz.aes")."'", true, true);


			// only restore basic settings and fonts - no projects
			copyFolder("~/$backup_file_name/dot_config", "~/.config/");

			copyFile("~/$backup_file_name/dot_bash_profile", "~/.bash_profile");
			copyFile("~/$backup_file_name/dot_gitconfig", "~/.gitconfig");
			copyFile("~/$backup_file_name/dot_gitignore_global", "~/.gitignore_global");
			copyFile("~/$backup_file_name/dot_tm_properties", "~/.tm_properties");
			copyFile("~/$backup_file_name/dot_anyconnect", "~/.anyconnect");
			copyFolder("~/$backup_file_name/dot_ssh/", "~/.ssh");

			copyFolder("~/$backup_file_name/Library/Fonts/", "~/Library/Fonts");

			copyFolder("~/$backup_file_name/Library/Application Support/Fork/", "~/Library/Application Support/Sequel Pro");
			copyFolder("~/$backup_file_name/Library/Application Support/Sequel Pro/", "~/Library/Application Support/Fork");

			copyFile("~/$backup_file_name/Library/Application Support/Sequel Pro/Data/Favorites.plist", "~/Library/Application Support/Sequel Pro/Data/Favorites.plist");
			copyFile("~/$backup_file_name/Library/Application Support/TextMate/Global.tmProperties", "~/Library/Application Support/TextMate/Global.tmProperties");
			copyFolder("~/$backup_file_name/Library/Application Support/TextMate/Bundles/", "~/Library/Application Support/TextMate/Bundles");

			command("chmod -R 777 '".$backup_folder."'", true, true);
			// delete backup folder
			// command("rm -R '".$backup_folder."'", true, true);

		}
		else {
			goodbye("Selection is not a valid backup.");
		}

	}
	else {
		goodbye("Selection is not a valid backup.");
	}

	
}
else {
	goodbye("Unknown backup");
}

goodbye("\nRestoring from $backup_device/$backup is done.");


?>