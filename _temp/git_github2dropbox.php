#!/usr/bin/php
<?php

$new_repo = isset($argv[1]) ? preg_replace("/\//", "", $argv[1]) : false;


if($new_repo) {

	// expect this script to be in Dropbox - use it to find Dropbox path
	list($dropbox_path) = explode("/Dropbox/", __FILE__);

	// check if local repo exists
	if(file_exists($dropbox_path . "/Dropbox/hvadhedderde/git/" . $new_repo . ".git")) {
	
		print "Dropbox repo exists, using existing repo\n";
		
	}
	// create dropbox repo
	else {
	
		print "Dropbox repo does not exist, creating ".$new_repo."\n";
	
		$output = shell_exec("cd ".$dropbox_path."/Dropbox/hvadhedderde/git && git init --bare ".$new_repo.".git");
		print ($output ? "$output\n" : "");
		
	}
	
	
	// make dropbox master
	$output = shell_exec("cd /srv/sites/clients/".$new_repo." && git remote rm origin && git remote add origin ~/Dropbox/hvadhedderde/git/".$argv[1].".git");
	print ($output ? "$output\n" : "");
	
	// push to master
	$output = shell_exec("cd /srv/sites/clients/".$new_repo." && git push -u origin master");
	print ($output ? "$output\n" : "");
	
	
	// check if all went well
	// TODO: add extra checks later
	if(file_exists($dropbox_path."/Dropbox/hvadhedderde/git/" . $new_repo . ".git")) {
	
		// delete github repo
		$_ = "curl -H 'Authorization: token bd5f689b0cae6754512bcd44f1238dc1ed7a3028' -X DELETE -d '{\"scopes\":[\"delete_repo\"]}' https://api.github.com/repos/hvadhedderde/".$new_repo;
		$output = shell_exec($_);
		$response = json_decode($output, true);
	
		if(isset($response["message"])) {
	
			print "Error deleting repo (".$response["message"].")\n";
			exit();
		
		}
		else {
			print "Github repo deleted\n";
		}
	
		print "DONE\n";
	}

}
else {
	
	print "No repo name??\n";
	
}

?>