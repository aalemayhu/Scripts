#!/bin/bash

output=`mktemp --suffix=.html`
echo "Writing to $output"

echo "<h1>checkpatch.pl output</h1>" >> $output
for file in `find . -name '*.c'`;
do
  echo "<h2>$file</h2>" >> $output
  echo "<div><code>" >> $output
  for line in $($HOME/src/github.com/scanf/linux/scripts/checkpatch.pl --file --terse $file)
  do
    echo "$line" >> $output
  done
  echo "</code></div>" >> $output
done
xdg-open $output
