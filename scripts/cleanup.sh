#!/bin/bash -e
git push origin master --force

git push --tags --force

rm -rf .git/refs/original/

git reflog expire --expire=now --all

git gc --aggressive --prune=now
