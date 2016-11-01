#!/bin/sh
apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y
apt-get autoclean
apt-get autoremove
