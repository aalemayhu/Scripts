#!/bin/bash
files=(./*.mp4)
video="${files[RANDOM % ${#files[@]}]}"

mplayer -fs "$video"

read -p "Would you like to delete $video?(n/y)" -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
  rm "$video"
else
  mv "$video" ../KEEP/
fi

echo
