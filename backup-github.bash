#!/bin/bash

# TODO: Check if github-backup is installed
github_dir=/home/a/src/github.com
logfile=$github_dir/scanf/backup-public.log

mkdir -p $github_dir/scanf
touch $logfile
cd $github_dir
echo "logging to $logfile"
echo "[`date`]" >> $logfile
github-backup scanf $github_dir/scanf >> $logfile
cd -
