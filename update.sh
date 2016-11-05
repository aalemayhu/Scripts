#!/bin/sh

if [ -f /etc/fedora-release ]; then
  dnf update
  dnf upgrade -y
  dnf clean
  dnf autoremove
elif [ -f /etc/debian-release ]; then
  apt-get update
  apt-get upgrade -y
  apt-get dist-upgrade -y
  apt-get autoclean
  apt-get autoremove
else
  echo "fatal: unsupported system"
fi
