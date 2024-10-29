#!/opt/local/bin/php
<?php
include("functions.php");

// start by requesting sudo power
enableSuperCow();

if(file_exists(".git/config")) {

	command("git config core.fileMode false");

	if(file_exists("submodules/janitor/.git")) {
		command("cd submodules/janitor && git config core.fileMode false");
	}
	if(file_exists("submodules/asset-builder/.git")) {
		command("cd submodules/asset-builder && git config core.fileMode false");
	}

}
else {
	print "This is not a git repos – git config cannot be updated";
	exit();
}
