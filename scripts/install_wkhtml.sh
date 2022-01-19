#!/bin/bash -e

# WKHTML
if [ "$install_wkhtml" = "Y" ]; then

	outputHandler "section" "Installing wkhtml"

	if [ $(fileExist "/srv/tools/bin/wkhtmltopdf") = "true" ]; then
		outputHandler "comment" "Deleting existing binary"
		command "sudo unlink /srv/tools/bin/wkhtmltopdf"
	fi

	outputHandler "comment" "Unpacking wkhtml bundle"
	command "sudo tar -xzf $BIN_DIR/wkhtml.tar.gz -C /srv/tools/bin"

	outputHandler "comment" "wkhtml: OK"

else
	outputHandler "comment" "Skipping wkhtml"
fi

