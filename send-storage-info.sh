#!/bin/sh

df -h | mail -s "storage info for `hostname`" alexander@alemayhu.com 
