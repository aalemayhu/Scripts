#!/bin/bash

for id in `docker ps -a | awk ' { print $1 } ' grep -v CONTAINER`; do docker rm -f $id; done
for id in `docker images | awk ' { print $3 } ' | grep -v NAMES | grep -v CONTAINER`; do docker rmi -f $id; done
