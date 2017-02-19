#!/bin/sh

if [ -f /etc/fedora-release ]; then
  dnf -v -y update
  dnf -v -y upgrade
  dnf -v -y clean packages
  dnf -v -y autoremove
elif [ -f /etc/debian-release ] || command -v apt-get > /dev/null; then
  apt-get update
  apt-get upgrade -y
  apt-get dist-upgrade -y
  apt-get autoclean
  apt-get autoremove
else
  echo "fatal: unsupported system"
fi
