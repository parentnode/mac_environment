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
				$output = shell_exec("cd $path/$file\ngit status -s");
				print "Repos: " . ($output ? "\e[0;31m$path/$file\n$output\n\e[0;34m" : "$path/$file\nNo uncomitted files\n\n");
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