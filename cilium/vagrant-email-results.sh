#!/bin/bash

export VAGRANT_LOG=debug

EMAIL="`mktemp`.email.txt"
REV="$(git --no-pager log -1 --pretty='tformat:%h (%s, %ad)' --date=short)"
SUBJECT="[BUILD$2]: [cilium]: $REV"
DATE="`date`"
FROM="Alexander Alemayhu <alexander@alemayhu.com>"
REPO=""

echo "From: $FROM" > $EMAIL
echo "Date: $DATE" >> $EMAIL
echo "Subject: $SUBJECT" >> $EMAIL

echo "PWD=`pwd`" >> $EMAIL
echo "" >> $EMAIL
echo "" >> $EMAIL

if [[ "$1" == "clone" ]]; then
  REPO=`mktemp`
  rm $REPO && mkdir $REPO
  git clone https://github.com/cilium/cilium $REPO >> $EMAIL 2>&1
  # TODO: check for a local cache, and git fetch then copy.
  cd $REPO
fi

RELOAD=1 ./contrib/vagrant/start.sh >> $EMAIL 2>&1
RUN_TEST_SUITE=1 ./contrib/vagrant/start.sh >> $EMAIL 2>&1

if [[ "$3" == "cleanup" ]]; then
  vagrant destroy -f >> $EMAIL 2>&1
  cd -
  rm -rvf $REPO >> $EMAIL 2>&1
fi

git send-email --no-validate --to alexander@covalent.io --suppress-cc=all $EMAIL
