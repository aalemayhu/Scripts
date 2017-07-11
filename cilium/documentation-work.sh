#!/bin/bash

check_for()
{
  if [ ! -f $1 ]; then
    echo "error: did not detect $1"
    echo "Please run in the Documentation directory!"
    exit
  fi
}

check_for conf.py
make clean

make latexpdf
cp `find . -name '*.pdf'` ~/src/github.com/scanf/alemayhu.com/c.pdf

make html
rsync -r _build/html/ ~/src/github.com/scanf/alemayhu.com/cilium-staging
