#!/bin/bash -e


outputHandler "comment" "Installing apache2 with http2"

command "sudo port uninstall apache2"
command "sudo port -N install apache2 +eventmpm +http2"
