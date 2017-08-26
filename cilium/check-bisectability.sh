#!/bin/bash

src="$1" # upstream/master
dst="$2" # HEAD

for rev in $(git rev-list $src..$dst); do
  git stash
  logfile="`mktemp`.build"
  git checkout $rev >> $logfile
  make clean >> $logfile
  if $(make >> $logfile 2>&1); then
    echo `tput setaf 2`PASS`tput sgr0`:`git ll`
    continue
  fi
  echo `tput setaf 1`FAIL`tput sgr0`:`git ll`
done
