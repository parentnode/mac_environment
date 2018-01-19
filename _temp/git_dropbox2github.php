#!/usr/bin/php
<?php

$new_repo = isset($argv[1]) ? preg_replace("/\//", "", $argv[1]) : false;


if($new_repo) {

	// check if repo exists
	$_ = "curl -H 'Authorization: token bd5f689b0cae6754512bcd44f1238dc1ed7a3028' https://api.github.com/orgs/hvadhedderde/repos";
	$output = shell_exec($_);
	$response = json_decode($output, true);

//	print_r($response);

	foreach($response as $repo) {
		if($repo["name"] == $new_repo) {
			
			print "Repo exists!\n";
			exit();

		}
	}

	// creating github repo
	print "Creating github repo: " . $new_repo . "\n";
	$_ = "curl -H 'Authorization: token bd5f689b0cae6754512bcd44f1238dc1ed7a3028' -d '{\"name\": \"".$new_repo."\", \"private\": true}' https://api.github.com/orgs/hvadhedderde/repos";

	$output = shell_exec($_);
	$response = json_decode($output, true);

	if(isset($response["errors"])) {

		print "Error creating repo\n";
		exit();
		
	}
	
	print $new_repo . " created\n";


	// make new repo master and push to master
	$_ = "cd /srv/sites/clients/".$argv[1] . " && git remote rm origin && git remote add origin https://github.com/hvadhedderde/".$new_repo.".git && git push -u origin master";
	$output = shell_exec($_);

	print $output;
	
}
else {
	
	print "No repo name??\n";
	
}

?>