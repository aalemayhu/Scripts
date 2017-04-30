#!/bin/bash

thermal_daemon_dir=src/github.com/01org/thermal_daemon

if [[ -d "$thermal_daemon_dir" ]]; then
  git clone https://github.com/01org/thermal_daemon $thermal_daemon_dir
else
  git -C $thermal_daemon_dir fetch --all
fi

cd $thermal_daemon_dir

su -c 'yum install -y automake gcc gcc-c++ glib-devel dbus-glib-devel libxml2-devel'

./autogen.sh
./configure prefix=/usr
make
su -c 'make install'

su -c 'systemctl start thermald.service'
su -c 'systemctl status thermald.service'
su -c 'systemctl stop thermald.service'

# Reference: https://github.com/01org/thermal_daemon
