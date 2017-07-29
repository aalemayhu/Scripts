#!/bin/bash

git branch -v -v
vagrant destroy -f && ./contrib/vagrant/start.sh
git branch -v -v
