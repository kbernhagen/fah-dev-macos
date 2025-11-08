#!/bin/bash -e
#  make-libraries-v8.sh
cd "$(dirname "$0")"
# make libs as needed
# delete existing libs to force rebuild
./make-fftw.sh
./make-openssl3.sh
