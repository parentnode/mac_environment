#!/usr/bin/php
<?php
include("functions.php");

output("Be patient, some tasks may take a while.");

// start by requesting sudo power
enableSuperCow();

// check software requirements
output("Checking for Xcode");
$is_ok_xcode = isInstalled("xcodebuild -version", array("Xcode 4", "Xcode 5", "Xcode 6", "Xcode 7"));
output($is_ok_xcode ? "Xcode is OK \n -----\n" : "Xcode check failed - update or install Xcode from AppStore");


output("Checking for Xcode command line tools");

//$is_ok_xcode_cl = isInstalled("gcc --version", array("Apple LLVM version"));
$is_ok_xcode_cl = isInstalled("pkgutil --pkg-info=com.apple.pkg.CLTools_Executables", array("version: 6", "version: 7"));
output($is_ok_xcode_cl ? "Xcode command line tools are OK \n -----\n" : "Xcode command line tools check failed - installing now");
if(!$is_ok_xcode_cl) {
	command("xcode-select --install");
	goodbye("Run the setup command again when the command line tools are installed");
}

output("Checking for Macports");
$is_ok_macports = isInstalled("port version", array("Version: 2"));
output($is_ok_macports ? "Macports is OK \n -----\n" : "Macports check failed - update or install Macports from macports.org");

// update macports
// TODO: re-enable
// command("sudo port selfupdate");


// check ffmpeg availability
output("Checking for ffmpeg");
$is_ok_ffmpeg = isInstalled("ffmpeg -version", array("ffmpeg version 2.7", "ffmpeg version 2.8"));
output($is_ok_ffmpeg ? "ffmpeg is OK \n -----\n" : "ffmpeg not found - installing now");
if(!$is_ok_ffmpeg) {
	command("sudo port install ffmpeg +nonfree");
}

// check php version
output("Checking for php");
$is_ok_php = isInstalled("port select php", array("php55 \(active\)"));
output($is_ok_php ? "PHP is OK \n -----\n" : "PHP 5.5 not found - installing now");
if(!$is_ok_php) {

	// uninstall old php?
	$cmd_output = shell_exec(escapeshellcmd("port select php")." 2>&1");
	preg_match("/php([\d]+)/i", $cmd_output, $matches);
	if(count($matches) > 1) {
		for($i = 1; $i < count($matches); $i++) {
			if($matches[$i] != "55") {
				output("Found old PHP:" . $matches[$i] . " - cleaning up");

				command("sudo port uninstall php".$matches[$i]."-apache2handler");

				command("sudo port uninstall php".$matches[$i]."-mysql");
				command("sudo port uninstall php".$matches[$i]."-openssl");
				command("sudo port uninstall php".$matches[$i]."-mbstring");
				command("sudo port uninstall php".$matches[$i]."-curl");
				command("sudo port uninstall php".$matches[$i]."-zip");
				command("sudo port uninstall php".$matches[$i]."-imagick");

				command("sudo port uninstall php".$matches[$i]);
			}
		}
	}

	// install php55
	output("Remember: Patience is a vitue! Now is the time to practice :-) \n -----\n");

//	command("sudo port install php55");
	command("sudo port install php55 +apache2 +mysql56-server +pear php55-apache2handler");
	
	command("sudo port select php php55");

	command("sudo port install php55-apache2handler");

	command("sudo port install php55-mysql");
	command("sudo port install php55-openssl");
	command("sudo port install php55-mbstring");
	command("sudo port install php55-curl");
	command("sudo port install php55-zip");
	command("sudo port install php55-imagick");

}


// output("Checking for AWStats");
// $is_ok_awstats = isInstalled("[ -f /opt/local/www/awstats/cgi-bin/awstats.pl ] && echo 'exists' || echo 'Not found'", array("exists"), false);
// output($is_ok_awstats ? "AWStats is OK" : "AWStats not found - installing now");
// if(!$is_ok_awstats) {
// 	command("sudo port install awstats");
// }


// check for imagick
output("Checking for PHP imagick");
$is_ok_imagick = isInstalled("[ -f /opt/local/lib/php55/extensions/no-debug-non-zts-20121212/imagick.so ] && echo 'exists' || echo 'Not found'", array("exists"), false);
output($is_ok_imagick ? "PHP imagick is OK" : "PHP imagick not found - installing now");
if(!$is_ok_imagick) {
	command("sudo port install php55-imagick");
}


// is software available
if(!$is_ok_xcode || !$is_ok_macports || !$is_ok_ffmpeg || !$is_ok_php || !$is_ok_imagick) {
	goodbye("Update your software as specified above");
}



// ensure sudo power before continuing
enableSuperCow();



output("\nChecking paths");

// check if configuration files are available
checkFile("_conf/httpd.conf", "Required file is missing from your configuration source");
checkFile("_conf/my.cnf", "Required file is missing from your configuration source");
checkFile("_conf/httpd-vhosts.conf", "Required file is missing from your configuration source");
checkFile("_conf/php.ini", "Required file is missing from your configuration source");
checkFile("_conf/apache.conf", "Required file is missing from your configuration source");
checkFile("~/.bash_profile", "Required file is missing from home directory");



output("\nCopying configuration");

// copy base configuration
copyFile("_conf/httpd.conf", "/opt/local/apache2/conf/httpd.conf", "sudo");
copyFile("_conf/httpd-vhosts.conf", "/opt/local/apache2/conf/extra/httpd-vhosts.conf", "sudo");

// copy apache log rotation conf
copyFile("_conf/newsyslog-apache.conf", "/etc/newsyslog.d/apache.conf", "sudo");

// copy php.ini
copyFile("_conf/php.ini", "/opt/local/etc/php55/php.ini", "sudo");

// copy my.cnf for MySQL (to override macports settings)
copyFile("_conf/my.cnf", "/opt/local/etc/mysql56/my.cnf", "sudo");

// copy php.ini.default for native configuration
copyFile("_conf/php_ini_native.ini", "/etc/php.ini", "sudo");


// copy wkhtmltox static executables
copyFile("_conf/static_wkhtmltoimage", "/usr/bin/static_wkhtmltoimage", "sudo");
copyFile("_conf/static_wkhtmltopdf", "/usr/bin/static_wkhtmltopdf", "sudo");



output("\nConfiguration copied");



// Add alias' to .bash_profile
checkFileContent("~/.bash_profile", "_conf/bash_profile.default");


// Add local domains to /etc/hosts
command("sudo chmod 777 /etc/hosts");
checkFileContent("/etc/hosts", "_conf/hosts.default");
command("sudo chmod 644 /etc/hosts");


// restart apache
command("sudo /opt/local/apache2/bin/apachectl restart");


// DONE
output("\n\nUpdate is completed - please restart your terminal");

?>