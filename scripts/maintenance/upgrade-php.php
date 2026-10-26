#!/opt/local/bin/php
<?php
include("../functions.php");

enableSuperCow();

$USERNAME = getCurrentUser();

$new_version = "85";
output("Upgrading to PHP".$new_version);


command("sudo port selfupdate");

$ports = explode("\n", command("sudo port installed", true));

foreach($ports as $port) {

	if(preg_match("/php([\d]*)[^ ]*/", $port, $match)) {

		// print_r($match);

		if(count($match) === 2) {

			$old_version = $match[1];
			$old_port = $match[0];

			// Not already new version
			if($old_version && $old_version !== $new_version) {

				// print "sudo port uninstall ".$old_port."\n";
				command("sudo port uninstall ".$old_port);

				$new_port = str_replace("php".$old_version, "php".$new_version, $old_port);
				// print $old_version."\n";
				// print $new_port."\n";

				// php_mod version, install fpm variant
				// if($new_port === "php".$new_version) {
				// 	print "sudo port install php".$new_version."-fpm\n";
				// // 	command("sudo port install php".$new_version."-fpm");
				// 	print "sudo port load php".$new_version."-fpm\n";
				// // 	command("sudo port load php".$new_version."-fpm");
				// }
				//
				// // php fpm module – unload old version
				// else
				if($new_port === "php".$new_version."-fpm") {

					// print "sudo port unload php".$old_version."-fpm\n";
					command("sudo port unload php".$old_version."-fpm");

					// print "sudo port install ".$new_port."\n";
					command("sudo port install ".$new_port);

					// print "sudo port load ".$new_port."\n";
					command("sudo port load ".$new_port);

				}

				// PHP or Extension module
				else {

					// print "sudo port install ".$new_port."\n";
					command("sudo port install ".$new_port);

				}

				

			}

		}

	}

}

// exit();

command("sudo port select --set php php".$new_version);


// $file = getAbsolutePath("/opt/local/etc/apache2/httpd.conf");
// $source_lines = file($file);
// $updated_lines = [];
//
// $found_php_8_module_include = false;
// $module_injection_point = false;
// $alternate_module_injection_point = false;
//
// $found_php_8_conf_include = false;
// $conf_injection_point = false;
//
// foreach($source_lines as $i => $line) {
//
// 	// found load module section, will eventually point to the last LoadModule entry
// 	if(strpos("LoadModule", $line) !== false) {
// 		$alternate_module_injection_point = $i;
// 	}
//
// 	// found php7 module
// 	if(strpos($line, "LoadModule php7_module") !== false) {
//
// 		// Already commented out
// 		if(preg_match("/#[ ]*LoadModule php7_module/", $line)) {
// 			$updated_lines[] = $line;
// 		}
// 		// Not commented out, should be
// 		else {
// 			$updated_lines[] = "# ".$line;
//
// 		}
// 		// This is a better injection point
// 		$module_injection_point = $i;
//
// 	}
// 	// Found PHP8+ module
// 	else if(strpos($line, "LoadModule php_module") !== false) {
// 		$found_php_8_module_include = true;
//
// 		// commented out?
// 		if(preg_match("/#[ ]?LoadModule php_module/", $line)) {
// 			$updated_lines[] = preg_replace("/^#[ ]*/", "", $line);
// 		}
// 		else {
// 			$updated_lines[] = $line;
// 		}
//
// 	}
//
// 	// found php7 conf
// 	else if(strpos($line, "mod_php74.conf") !== false) {
//
// 		if(preg_match("/#[ ]?Include/", $line)) {
// 			$updated_lines[] = $line;
// 		}
// 		else {
// 			$updated_lines[] = "# ".$line;
//
// 		}
// 		// This is a better injection point
// 		$conf_injection_point = $i;
//
// 	}
// 	else if(strpos($line, "mod_php82.conf") !== false) {
// 		$found_php_8_conf_include = true;
//
// 		// commented out?
// 		if(preg_match("/#[ ]?Include/", $line)) {
// 			$updated_lines[] = preg_replace("/^#[ ]*/", "", $line);
// 		}
// 		else {
// 			$updated_lines[] = $line;
// 		}
//
// 	}
// 	else {
// 		$updated_lines[] = $line;
// 	}
//
// }
//
// // Existing loadmodule not found
// if(!$found_php_8_module_include) {
//
// 	$module = "LoadModule php_module lib/apache2/modules/mod_php82.so\n";
//
// 	// inject in correct place in file (injection point or alternate injection point)
// 	if($module_injection_point) {
// 		array_splice($updated_lines, $module_injection_point+1, 0, $module);
// 	}
// 	else if($alternate_module_injection_point) {
// 		array_splice($updated_lines, $alternate_module_injection_point+1, 0, $module);
// 	}
// 	else {
// 		$updated_lines[] = $module;
// 	}
//
// 	if($conf_injection_point) {
// 		$conf_injection_point++;
// 	}
//
// }
//
// // Existing loadmodule not found
// if(!$found_php_8_conf_include) {
//
// 	$conf = "Include etc/apache2/extra/mod_php84.conf\n";
//
// 	// inject in correct place in file (injection point or alternate injection point)
// 	if($conf_injection_point) {
// 		array_splice($updated_lines, $conf_injection_point+1, 0, $conf);
// 	}
// 	else {
// 		$updated_lines[] = $conf;
// 	}
//
// }

// if(!file_exists("/opt/local/etc/php85/php.ini")) {

	copyFile("conf/php-".$new_version.".ini", "/opt/local/etc/php".$new_version."/php.ini", "sudo");
	copyFile("conf/php-native-".$new_version.".ini", "/etc/php.ini", "sudo");
// }


copyFile("conf/php-".$new_version."-fpm.conf", "/opt/local/etc/php".$new_version."/php-fpm.conf", "sudo");
copyFile("conf/php-".$new_version."-fpm-www.conf", "/opt/local/etc/php".$new_version."/php-fpm.d/www.conf", "sudo");

command("sudo sudo sed -i '' 's/###USERNAME###/$USERNAME/g' '/opt/local/etc/php".$new_version."/php-fpm.d/www.conf'");


command("sudo sudo sed -i '' 's/php8[0-9]/php".$new_version."/g' '/opt/local/etc/apache2/httpd.conf'");

// $file = file_get_contents("/opt/local/etc/apache2/httpd.conf");
// $file = preg_replace("/php8[1-9]/", "php".$new_version, $file);
// command("sudo chown staff /opt/local/etc/apache2/httpd.conf");
// file_put_contents("/opt/local/etc/apache2/httpd.conf", $file);
// command("sudo chown root /opt/local/etc/apache2/httpd.conf");


//
// sudo cp "$CONF_DIR/php-fpm.conf" "/opt/local/etc/php82/php-fpm.conf"
// sudo cp "$CONF_DIR/php-fpm-www.conf" "/opt/local/etc/php82/php-fpm.d/www.conf"
// sudo sed -i '' "s/###USERNAME###/$INSTALL_USER/g" "/opt/local/etc/php82/php-fpm.d/www.conf"
//
//
// # autostart apache on reboot
// outputHandler "comment" "Autostart apache2"
// command "sudo port load apache2"
//
// # autostart PHP-FPM on reboot
// outputHandler "comment" "Autostart PHP-FPM"
// command "sudo port load php82-fpm"
//

// write file back out
// $fp = fopen($file, "w+");
// foreach($updated_lines as $line) {
// 	fwrite($fp, $line);
// }
// fclose($fp);


command("sudo /opt/local/sbin/apachectl restart");

command("sudo port reload php".$new_version."-fpm");
