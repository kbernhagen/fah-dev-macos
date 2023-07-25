#!/bin/bash -e

#  make-libraries.sh

cd "$(dirname "$0")"

# make libs as needed
# delete existing libs to force rebuild
./make-fftw.sh
./make-freetype.sh
./make-openssl3.sh
