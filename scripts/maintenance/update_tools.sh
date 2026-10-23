#!/bin/bash

echo "-----------------------------------------"
echo
echo "       UPDATING PARENTNODE TOOLS"
echo
echo

cd /srv/tools && sudo git pull

source /srv/tools/conf/dot_pnstack_aliases
