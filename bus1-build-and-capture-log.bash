#!/bin/bash

branch=`git rev-parse --abbrev-ref HEAD`
echo Using $branch

make tt > /tmp/$branch.output 2>&1 
