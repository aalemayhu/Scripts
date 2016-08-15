#!/bin/bash
sudo mount -t ext3 /dev/sdb1  /media/extern/
sudo mount -o remount,rw /dev/sdb1 /media/extern
