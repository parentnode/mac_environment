#!/bin/bash -e
source /srv/sites/parentnode/mac_environment/scripts/functions.sh

syncronizeAlias "alias" "/srv/tools/conf/dot_profile_alias" "$HOME/.bash_profile"