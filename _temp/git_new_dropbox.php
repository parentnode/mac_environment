#!/usr/bin/php
<?php

$repos = preg_replace("/\//", "", $argv[1]);

// create a git repo from argument folder
$output = shell_exec("cd /srv/sites/clients/" . $repos . " && git init && git add . && git commit -m \"initial commit\"");
print ($output ? "$output\n" : "");

// create dropbox repo
$output = shell_exec("cd ~/Dropbox/hvadhedderde/git && git init --bare " . $repos . ".git");
print ($output ? "$output\n" : "");

// make dropbox master
$output = shell_exec("cd /srv/sites/clients/" . $repos . " && git remote add origin ~/Dropbox/hvadhedderde/git/" . $repos . ".git");
print ($output ? "$output\n" : "");

// push to master
$output = shell_exec("cd /srv/sites/clients/" . $repos . " && git push -u origin master");
print ($output ? "$output\n" : "");

?>