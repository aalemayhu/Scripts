#!/bin/sh
./configure CFLAGS='-g -O0 -ftrapv' --enable-compat-libs --enable-kdbus --sysconfdir=/etc --localstatedir=/var --libdir=/usr/lib --with-rootprefix= --with-rootlibdir=/lib
make -j8
/usr/bin/sudo make install
