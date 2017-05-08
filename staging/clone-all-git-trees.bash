#!/bin/bash

MAINTAINERS_FILE=https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/plain/MAINTAINERS

curl -sSL $MAINTAINERS_FILE | grep "git:" | awk ' { print $3 } ' |sort -u | while read -r repo
do
  if [[ "$repo" == "" ]]; then
    continue
  fi

  dir=$HOME/src/`echo $repo | sed 's/git\?:\/\///'`
  if [[ -d "$dir" ]]; then
    git -C "$dir" fetch --all
  else
    git clone "$repo" "$dir"
  fi
done