#!/bin/bash

echo "-----------------------------------------"
echo
echo "       UPDATING PARENTNODE TOOLS"
echo
echo

cd /srv/tools && git pull

source /srv/tools/conf/dot_bash_aliases
