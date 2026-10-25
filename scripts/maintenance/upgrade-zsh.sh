#!/bin/bash

# Include functions
TOOLS_DIR="/srv/tools"

CONF_DIR="$TOOLS_DIR/conf"
export CONF_DIR

source "$TOOLS_DIR/scripts/functions.sh"
source "$CONF_DIR/dot_pnstack_aliases"


# Current Username logged in
INSTALL_USER=$(getUsername)
export INSTALL_USER


# Request sudo privileges
enableSuperCow


# Oh my zsh
if [ $(fileExist "/Users/$INSTALL_USER/.oh-my-zsh") = "false" ]; then
	command "sh -c $(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi



# Check for .zshrc, create if it doesn't exist (it should after installing oh my zsh)
if [ $(fileExist "/Users/$INSTALL_USER/.zshrc") = "false" ]; then
	touch "/Users/$INSTALL_USER/.zshrc"
fi

# Include pnstack profile
if ! grep -q "source /srv/tools/conf/dot_pnstack_profile" "/Users/$INSTALL_USER/.zshrc"; then
	echo "" >> "/Users/$INSTALL_USER/.zshrc"
	echo "# parentNode Stack extension" >> "/Users/$INSTALL_USER/.zshrc"
	echo "source /srv/tools/conf/dot_pnstack_profile" >> "/Users/$INSTALL_USER/.zshrc"
	echo "" >> "/Users/$INSTALL_USER/.zshrc"
fi
