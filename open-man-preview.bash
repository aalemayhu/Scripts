#!/bin/bash
# From: http://hints.macworld.com/article.php?story=20051225101106519

RENDER_FILE="/tmp/$1-`date`".ps

man -t $1 > "$RENDER_FILE"

unamestr=`uname`
if [[ "$unamestr" == 'Darwin' ]]; then
  cat "$RENDER_FILE" | open -f -a /Applications/Preview.app
else
  xdg-open "$RENDER_FILE"
fi
