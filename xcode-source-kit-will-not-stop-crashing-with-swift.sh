#!/bin/sh
# http://stackoverflow.com/questions/27083848/xcode-source-kit-will-not-stop-crashing-with-swift

# https://agilewarrior.wordpress.com/2012/06/28/how-to-kill-xcode-from-the-command-line/
kill $(ps aux | grep 'Xcode' | awk '{print $2}')
rm -rvf ~/Library/Developer/Xcode/DerivedData/
rm -rvf ~/Library/Caches/com.apple.dt.Xcode
echo "To restart osascript -e 'tell app "System Events" to shut down'"
