#!/bin/bash
for process in `ps aux | grep Virtual|awk ' { print $2 } '`;
do
  kill -9 $process
done
