#!/bin/bash

PROJECT=scanf/cilium

build() {
  docker build -t ${PROJECT} .
}

deploy() {
  build 
  push
  echo "Pushed to docker"
}

run() {
  build
  docker run -t -i ${PROJECT} /bin/bash
}

push() {
  docker push ${PROJECT}
}

eval $1
