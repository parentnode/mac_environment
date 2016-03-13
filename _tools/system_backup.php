#!/usr/bin/php
<?php
include("functions.php");

// start by requesting sudo power
enableSuperCow();


$full = ask("Make full backup? (y/n)", array("y", "n"), false);

if($full == "y") {
	
	goodbye("Not implemented yet");

	// should copy to external drive
	
}
// make minpr backup to Dropbox
else {

	output("Creating quick backup");

	$backup_time = date("Ymd_His");

	if(file_exists(getAbsolutePath("~/Dropbox/backup"))) {
		$backup_path = getAbsolutePath("~/Dropbox/backup/").$backup_time;
	}
	else if(file_exists(getAbsolutePath("~/Google\ Drive/backup"))) {
		$backup_path = getAbsolutePath("~/Google\ Drive/backup/").$backup_time;
	}
	else {
		goodbye("Could not find Dropbox or Google Drive for backup. You should create a folder named 'backup' to enable backup.");
	}

	if(!file_exists($backup_path)) {
		mkdir($backup_path);
	}


	output("Backup location:" . $backup_path."\n");


	// Applications list
	$root_applications = scandir("/Applications");
	array_unshift($root_applications, "Root apps:");
	$home_applications = scandir(getAbsolutePath("~/Applications"));
	array_unshift($home_applications, "Home apps:");
	file_put_contents($backup_path."/Applications.txt", implode("\n", array_merge($root_applications, $home_applications)));
	output("Created applications list\n");

	// Macports list
	$port_output = shell_exec("sudo port installed requested"." 2>&1");
	file_put_contents($backup_path."/Macports.txt", $port_output);
	output("Created Macports list\n");


	// MySQL
	command("php ".$_SERVER["HOME"]."/".dirname($_SERVER["PHP_SELF"])."/mysql_dump_all.php mysqldump", true, false);
	moveFile("~/mysqldump.sql", $backup_path."/mysqldump.sql");

	// config files
	copyFile("~/.bash_profile", $backup_path."/bash_profile");
	copyFile("~/.gitconfig", $backup_path."/gitconfig");
	copyFile("~/.gitignore_global", $backup_path."/gitignore_global");
	copyFile("~/.tm_properties", $backup_path."/tm_properties");
	copyFile("/etc/hosts", $backup_path."/hosts");

	


	copyFolder("~/Sites/apache/", $backup_path."/Sites/apache/");
	copyFolder("~/Desktop/", $backup_path."/Desktop/");
	copyFolder("~/Pictures/", $backup_path."/Pictures/");
	copyFolder("~/Documents/", $backup_path."/Documents/");
	copyFolder("~/Library/Keychains/", $backup_path."/Library/Keychains/");
	copyFolder("~/Library/Preferences/", $backup_path."/Library/Preferences/");
	copyFolder("~/Library/Fonts/", $backup_path."/Library/Fonts/");
	copyFolder("~/Library/Application Support/Firefox/", $backup_path."/Library/Application Support/Firefox");
	copyFolder("~/Library/Application Support/Sequel Pro/", $backup_path."/Library/Application Support/Sequel Pro/");
	copyFolder("~/Library/Application Support/SourceTree/", $backup_path."/Library/Application Support/SourceTree/");
	copyFolder("~/Library/Application Support/TextMate/", $backup_path."/Library/Application Support/TextMate/");


	// run git status 
	$port_output = shell_exec("sudo port installed requested"." 2>&1");
	file_put_contents($backup_path."/Macports.txt", $port_output);
	output("Created Macports list\n");


	// TODO
	// - copy any file which has not been comitted
	// - push any repos with un-pushed commits
	$git_output = shell_exec("php ".$_SERVER["HOME"]."/".dirname($_SERVER["PHP_SELF"])."/git_status.php"." 2>&1");
	print $git_output;

//	file_put_contents($backup_path."/Macports.txt", $port_output);




	// TODO
	// output("Removing old backups");

}


// try to enable cronjob to open dialog once every week to remind user about making backup
// osascript -e 'tell app "System Events" to display dialog "Run backup script now?"'

// Prompt for destination?


// Dump all databases (requires password)

// List of Applications content

// List of MacPorts installs

// ~/Library/Keychains/*
// ~/Library/Preferences/*
// ~/Library/Fonts/*
// ~/Library/Application Support/Firefox/*
// ~/Library/Application Support/Sequel Pro/*
// ~/Library/Application Support/SourceTree/*
// ~/Library/Application Support/TextMate/*
// ~/Pictures/*
// ~/Documents/*
// ~/Desktop/*
// ~/.bash_profile
// ~/.gitconfig
// ~/.gitignore_global
// ~/.tm_properties
// ~/.ssh/* (should be encrypted) - should not be moved
// /etc/hosts

// ~/Google Drive/*
// ~/Dropbox/*
// ~/Sites/*
// ~/Music/*
// ~/Downloads/*



?>