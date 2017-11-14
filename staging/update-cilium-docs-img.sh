#!/bin/bash
 
make docs-container
docker tag cilium/docs-builder docker.io/cilium/docs-builder
docker push docker.io/cilium/docs-builder
