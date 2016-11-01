#!/bin/sh 

alias gshort='git show -s --pretty='\''tformat: %h (%s, %ad)'\'' --date=short'
echo `gshort | awk ' { print $1 } '`-"`basename $(pwd)`"
