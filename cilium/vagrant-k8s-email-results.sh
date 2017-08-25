#!/bin/bash

cd ./tests/k8s && vagrant destroy -f && cd - || cd -
export VAGRANT_LOG=debug

EMAIL="`mktemp`.build"
REV="$(git --no-pager log -1 --pretty='tformat:%h (%s, %ad)' --date=short)"
SUBJECT="[BUILD]: [cilium]: $REV"
DATE="`date`"
FROM="Alexander Alemayhu <alexander@alemayhu.com>"

echo "Using $EMAIL"
echo "From: $FROM" > $EMAIL
echo "Date: $DATE" >> $EMAIL
echo "Subject: $SUBJECT" >> $EMAIL
echo "" >> $EMAIL

pwd >> $EMAIL 2>&1
git ll >> $EMAIL 2>&1
./tests/k8s/start.sh >> $EMAIL 2>&1

git send-email --no-validate --to alexander@covalent.io --suppress-cc=all $EMAIL
