#!/bin/bash

export VAGRANT_LOG=debug

EMAIL="`mktemp`.build"
REV="$(git --no-pager log -1 --pretty='tformat:%h (%s, %ad)' --date=short)"
SUBJECT="[BUILD]: [cilium]: $REV"
DATE="`date`"
FROM="Alexander Alemayhu <alexander@alemayhu.com>"

echo "From: $FROM" > $EMAIL
echo "Date: $DATE" >> $EMAIL
echo "Subject: $SUBJECT" >> $EMAIL

echo "PWD=`pwd`" >> $EMAIL
echo "" >> $EMAIL
echo "" >> $EMAIL

RELOAD=1 ./contrib/vagrant/start.sh >> $EMAIL 2>&1
RUN_TEST_SUITE=1 ./contrib/vagrant/start.sh >> $EMAIL 2>&1

git send-email --no-validate --to alexander@covalent.io --suppress-cc=all $EMAIL
