#!/bin/sh

filename=$(git status -s | basename `awk ' { print $2 } '`)
git add .
git commit -m "enforce 80 column in $filename"
