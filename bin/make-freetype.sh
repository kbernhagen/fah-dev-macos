#!/bin/bash -e

#  make-freetype.sh

if [ -z "$FAH_DEV_ROOT" ]; then
  echo "FAH_DEV_ROOT is not defined"
  exit 1
fi

export SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
export MACOSX_DEPLOYMENT_TARGET=10.7
PFIX="$HOME/fah-local-10.7-universal"

[ -f "$PFIX/lib/libfreetype.a" ] && exit 0

F="freetype-2.10.4.tar.gz"
D="freetype-2.10.4"

cd "$FAH_DEV_ROOT/build"

[ -d "$D" ] && rm -r "$D"

echo "extracting $F"
tar xzf "$F"
cd "$D"

# directly build universal

./configure --disable-shared --prefix="$PFIX" \
  CFLAGS="-arch arm64 -arch x86_64 -std=c99" \
  --without-png --enable-freetype-config
make
make install

echo "cleaning up"
cd ..
# rm source dir, but keep tar.gz
[ -d "$D" ] && rm -rf "$D"
