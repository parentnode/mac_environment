#!/usr/bin/php
<?php
    // check software requirements
    output("Checking Xcode version");
    $is_ok_xcode = isInstalled("xcodebuild -version", array("Xcode 4", "Xcode 5", "Xcode 6", "Xcode 7", "Xcode 8", "Xcode 9", "Xcode 10"));
    output($is_ok_xcode ? "Xcode is OK" : "Xcode check failed - update or install Xcode from AppStore");
    if(!$is_ok_xcode) {
    	goodbye("Run the setup command again when the command line tools are installed");
    }


    output("Checking Xcode command line tools version");
    $is_ok_xcode_cl = isInstalled("pkgutil --pkg-info=com.apple.pkg.CLTools_Executables", array("version: 6", "version: 7", "version: 8", "version: 9", "version: 10"));
    output($is_ok_xcode_cl ? "Xcode command line tools are OK" : "Xcode command line tools check failed - installing now");
    if(!$is_ok_xcode_cl) {
    	command("xcode-select --install");
    	goodbye("Run the setup command again when the command line tools are installed");
    }


    output("Checking for Macports");
    $is_ok_macports = isInstalled("port version", array("Version: 2"));
    output($is_ok_macports ? "Macports is OK" : "Macports check failed - update or install Macports from macports.org, or restart your terminal, if you have already installed macports.");

    // is software available
    if(!$is_ok_macports) {
    	goodbye("Update your software as specified above");
    }

    //exit("End of pre install check");
?>