#!/bin/bash

check_for()
{
  if [ ! -f $1 ]; then
    echo "error: did not detect $1"
    echo "Please run in the Documentation directory!"
    exit
  fi
}

OUTPUT_DIR=~/src/github.com/scanf/alemayhu.com
PDF_OUTPUT=c.pdf
HTML_OUTPUT=cilium-staging

check_for conf.py
make clean

make latexpdf
cp `find . -name '*.pdf'` $OUTPUT_DIR/$PDF_OUTPUT

make html
rsync -r _build/html/ $OUTPUT_DIR/$HTML_OUTPUT

echo PDF output can be found at $OUTPUT_DIR/$PDF_OUTPUT
echo HTML output can be found at $OUTPUT_DIR/$HTML_OUTPUT

echo WEB :
echo https://alemayhu.com/$PDF_OUTPUT
echo https://alemayhu.com/$HTML_OUTPUT
