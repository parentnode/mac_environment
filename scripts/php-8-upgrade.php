#!/opt/local/bin/php
<?php
include("functions.php");

enableSuperCow();

command("sudo port selfupdate");

$ports = explode("\n", command("sudo port installed requested", true));

foreach($ports as $port) {

	if(strpos($port, "php74") !== false) {

		preg_match("/php74[^ ]*/", $port, $match);

		$old_port = $match[0];
		// print "sudo port uninstall ".$old_port."\n";
		// command("sudo port uninstall ".$old_port, true);

		$new_port = str_replace("php74", "php82", $old_port);
		// print "sudo port install ".$new_port."\n";
		command("sudo port install ".$new_port);
//
//
//
//
// 		// Include etc/apache2/extra/mod_php74.conf
// 		// Include etc/apache2/extra/mod_php82.conf
//
// 		/*
// 		#LoadModule php7_module lib/apache2/modules/mod_php74.so
// 		LoadModule php_module lib/apache2/modules/mod_php82.so
// 		*/
	}

}


$file = getAbsolutePath("/opt/local/etc/apache2/httpd.conf");
$source_lines = file($file);
$updated_lines = [];

$found_php_8_module_include = false;
$module_injection_point = false;
$alternate_module_injection_point = false;

$found_php_8_conf_include = false;
$conf_injection_point = false;

foreach($source_lines as $i => $line) {

	// found load module section, will eventually point to the last LoadModule entry
	if(strpos("LoadModule", $line) !== false) {
		$alternate_module_injection_point = $i;
	}

	// found php7 module
	if(strpos($line, "LoadModule php7_module") !== false) {

		if(preg_match("/#[ ]*LoadModule php7_module/", $line)) {
			$updated_lines[] = $line;
		}
		else {
			$updated_lines[] = "# ".$line;
			
		}
		// This is a better injection point
		$module_injection_point = $i;

	}
	else if(strpos($line, "LoadModule php_module") !== false) {
		$found_php_8_module_include = true;

		// commented out?
		if(preg_match("/#[ ]?LoadModule php_module/", $line)) {
			$updated_lines[] = preg_replace("/^#[ ]*/", "", $line);
		}
		else {
			$updated_lines[] = $line;
		}

	}

	// found php7 conf
	else if(strpos($line, "mod_php74.conf") !== false) {

		if(preg_match("/#[ ]?Include/", $line)) {
			$updated_lines[] = $line;
		}
		else {
			$updated_lines[] = "# ".$line;
			
		}
		// This is a better injection point
		$conf_injection_point = $i;

	}
	else if(strpos($line, "mod_php82.conf") !== false) {
		$found_php_8_conf_include = true;

		// commented out?
		if(preg_match("/#[ ]?Include/", $line)) {
			$updated_lines[] = preg_replace("/^#[ ]*/", "", $line);
		}
		else {
			$updated_lines[] = $line;
		}

	}
	else {
		$updated_lines[] = $line;
	}

}

// Existing loadmodule not found
if(!$found_php_8_module_include) {

	$module = "LoadModule php_module lib/apache2/modules/mod_php82.so\n";

	// inject in correct place in file (injection point or alternate injection point)
	if($module_injection_point) {
		array_splice($updated_lines, $module_injection_point+1, 0, $module);
	}
	else if($alternate_module_injection_point) {
		array_splice($updated_lines, $alternate_module_injection_point+1, 0, $module);
	}
	else {
		$updated_lines[] = $module;
	}

	if($conf_injection_point) {
		$conf_injection_point++;
	}
	
}

// Existing loadmodule not found
if(!$found_php_8_conf_include) {

	$conf = "Include etc/apache2/extra/mod_php82.conf\n";

	// inject in correct place in file (injection point or alternate injection point)
	if($conf_injection_point) {
		array_splice($updated_lines, $conf_injection_point+1, 0, $conf);
	}
	else {
		$updated_lines[] = $conf;
	}

}

if(!file_exists("/opt/local/etc/php82/php.ini")) {
	copyFile("conf/php-82.ini", "/opt/local/etc/php82/php.ini");
}


// write file back out
$fp = fopen($file, "w+");
foreach($updated_lines as $line) {
	fwrite($fp, $line);
}
fclose($fp);


command("/opt/local/sbin/apachectl restart");
?>