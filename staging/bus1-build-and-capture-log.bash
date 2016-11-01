#!/bin/bash

echo "Starting with clean"

make clean

branch=`git rev-parse --abbrev-ref HEAD`
echo Using $branch

make tt > /tmp/$branch.output 2>&1 
