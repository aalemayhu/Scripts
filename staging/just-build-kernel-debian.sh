#!/bin/sh

output=$HOME/builds/

fakeroot make-kpkg clean
fakeroot make-kpkg --jobs=$1 --initrd kernel_image kernel_headers modules_image

mkdir -pv $output
mv ../*.deb $output
