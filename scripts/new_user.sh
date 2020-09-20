#!/bin/bash -e

source /srv/tools/scripts/functions.sh

outputHandler "section" "Setting up parentnode webstack for a new mac user"

cp /srv/tools/conf/dot_bash_profile ~/.bash_profile
outputHandler "comment" "exit and open the terminal to setup the final steps of your current user"