#!/usr/bin/php
<?php

/**
* Iterate through config folder
*
* @param string $path Path of iteration
*/
function folderIterator($path){

	$path = preg_replace("/\~/", $_SERVER['HOME'], $path);

	$handle = opendir($path);
	while($file = readdir($handle)){
		if($file != "." && $file != ".." && is_dir("$path/$file")) {
			if(is_dir("$path/$file/.git") && (basename($path) == "clients" || basename($path) == "e-types" || basename($path) == "kaestel" || basename($path) == "parentnode")) {
				// get simple status
				print "Repos: $path/$file\n";

				$output = shell_exec("cd $path/$file\ngit status -s");
				if($output) {
					print "\e[0;31m$output\e[0;34m\n";
				}
				else {
					// check for unpushed commits
					$output = shell_exec("cd $path/$file\ngit status");
					if(preg_match("/branch is ahead[^$]+by ([\d]+) commit/", $output, $match)) {
						print "\e[0;31m".$match[1]." unpushed commits\e[0;34m\n\n";
					}
					else {
						print "No uncomitted files\n\n";
					}
				}
			}
			else {
				if($file == "clients" || $file == "e-types" || $file == "parentnode" || $file == "kaestel") {
					folderIterator("$path/$file");
				}
			}
		}
	}
	closedir($handle);
}

folderIterator("~/Sites");

?>