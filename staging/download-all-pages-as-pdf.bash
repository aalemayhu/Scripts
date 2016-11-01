#!/bin/bash

#FROM: http://stackoverflow.com/questions/6593531/running-a-limited-number-of-child-processes-in-parallel-in-bash
function max15 {
   while [ `jobs | wc -l` -ge 15 ]
   do
      sleep 2
   done
}

url=$1

for url in $(lynx -dump -listonly "$url" | awk ' { print $2 } ')
do
  title=$(echo $url | shasum |tr -d ' ')
  echo "> GET $title $url"
  if [[ $title = *[!\ ]* ]]; then
    echo "Downloading "$url" to "$title".pdf"
    max15; wkhtmltopdf --no-background "$url" "$title".pdf &
  else
    echo "Skipping $url"
  fi
done
