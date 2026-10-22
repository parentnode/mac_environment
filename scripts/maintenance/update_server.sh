#!/bin/bash

echo "-----------------------------------------"
echo
echo "            UPDATING SERVER"
echo
echo
sudo port selfupdate
sudo port upgrade outdated
