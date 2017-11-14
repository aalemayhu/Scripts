#!/bin/bash

TAG=$1

docker build -t scanf/cilium$TAG .
docker tag scanf/cilium$TAG docker.io/scanf/cilium$TAG
docker push docker.io/scanf/cilium$TAG
