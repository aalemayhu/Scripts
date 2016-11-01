#!/bin/sh
fakeroot make-kpkg clean
make localmodconfig
fakeroot make-kpkg --jobs=4 --initrd kernel_image kernel_headers modules_image
/usr/bin/sudo dpkg -i ../*.deb
mkdir -p ~/old-kernel-builds
mv ../*.deb ~/old-kernel-builds
echo "You might want install missing modules (sudo make modules_install)"
