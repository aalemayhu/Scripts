#!/bin/bash

for d in *.pdf;
do
  page_count=`exiftool "$d" | grep 'Page Count' | cut -c35-`
  mkdir -p $page_count
  mv "$d" $page_count/
done
