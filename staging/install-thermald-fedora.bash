#!/bin/bash

git clone https://github.com/01org/thermal_daemon src/github.com/01org/thermal_daemon
cd src/github.com/01org/thermal_daemon

yum install -y automake
yum install -y gcc
yum install -y gcc-c++
yum install -y glib-devel
yum install -y dbus-glib-devel
yum install -y libxml2-devel

./autogen.sh
./configure prefix=/usr
make
make install

systemctl start thermald.service
systemctl status thermald.service
systemctl stop thermald.service

# Reference: https://github.com/01org/thermal_daemon
