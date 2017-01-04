#!/bin/sh

if [ -f /etc/fedora-release ]; then
  dnf -y update
  dnf -y upgrade
  dnf clean packages
  dnf autoremove
elif [ -f /etc/debian-release ] || command -v apt-get > /dev/null; then
  apt-get update
  apt-get upgrade -y
  apt-get dist-upgrade -y
  apt-get autoclean
  apt-get autoremove
else
  echo "fatal: unsupported system"
fi
