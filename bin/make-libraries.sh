#!/bin/bash -e

#  make-libraries.sh

cd "$(dirname "$0")"
cd ..
export FAH_DEV_ROOT="$PWD"

# download files and check sha256
./bin/getdownloads.sh

# make libs as needed
# delete existing libs to force rebuild
./bin/make-fftw.sh
./bin/make-freetype.sh
./bin/make-openssl.sh
