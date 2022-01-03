#!/bin/bash -e

#  getdownloads.sh

cd "$(dirname "$0")"

. ./env.sh

D="$FAH_DEV_ROOT/build"
mkdir -p "$D"
cd "$D"

echo
echo "Downloading files if necessary..."
echo

echo python-2.7.18-macosx10.9.pkg
[ ! -f python-2.7.18-macosx10.9.pkg ] && \
curl -fsSLO https://www.python.org/ftp/python/2.7.18/python-2.7.18-macosx10.9.pkg

echo freetype-2.11.1.tar.gz
[ ! -f freetype-2.11.1.tar.gz ] && \
curl -fsSLO https://download.savannah.gnu.org/releases/freetype/freetype-2.11.1.tar.gz

echo openssl-1.1.1m.tar.gz
[ ! -f openssl-1.1.1m.tar.gz ] && \
curl -fsSLO https://www.openssl.org/source/openssl-1.1.1m.tar.gz

# libpng is not needed
# freetype is built --without-png
# latest libpng also requires macos 10.13+
#echo libpng-1.6.37.tar.gz
#[ ! -f libpng-1.6.37.tar.gz ] && \
#curl -fsSLO https://download.sourceforge.net/libpng/libpng-1.6.37.tar.gz

echo fftw-3.3.10.tar.gz
[ ! -f fftw-3.3.10.tar.gz ] && \
curl -fsSLO https://www.fftw.org/fftw-3.3.10.tar.gz

# verify downloads
echo
echo "Checking sha256..."
echo
shasum -a 256 -c "$FAH_DEV_ROOT/etc/downloads.sha256.txt"
echo
