#!/bin/bash

# WIP - Script for checking a kernel setup

KDIR=$1 # Kernel tree

# TODO: redirect all output to log file
echo "Entering kernel tree"
cd $KDIR

make headers_install

echo "Entering testing directory"
cd tools/testing/selftests/bpf/
make
sudo ./test_verifier
sudo make run_tests #TODO: add a verbose option, env var?

# TODO: run all of the samples/bpf programs

# TODO: check all BPF configs are added.

# TODO: generate HTML and PDF from test results

# TODO: email results.
