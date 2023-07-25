#!/bin/bash -e

#  make-freetype.sh

cd "$(dirname "$0")"

source ./env.sh

if [ -z "$FAH_DEV_ROOT" ]; then
  echo "FAH_DEV_ROOT is not defined"
  exit 1
fi

export SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
export MACOSX_DEPLOYMENT_TARGET=10.7
PFIX="$HOME/fah-local-10.7-universal"

[ -f "$PFIX/lib/libfreetype.a" ] && exit 0

F="freetype-2.11.1.tar.gz"
D="freetype-2.11.1"
URL="https://download.savannah.gnu.org/releases/freetype/$F"
SHA256="f8db94d307e9c54961b39a1cc799a67d46681480696ed72ecf78d4473770f09b"

cd "$FAH_DEV_ROOT/build"

[ ! -f "$F" ] && curl -fsSLO "$URL"

echo -n "$SHA256  $F" | shasum -a 256 -c || $(rm "$F" && exit 1)

[ -d "$D" ] && rm -rf "$D"

echo "extracting $F"
tar xzf "$F"
cd "$D"

# directly build universal

./configure --disable-shared --prefix="$PFIX" \
  CFLAGS="-arch arm64 -arch x86_64 -std=c99" \
  --without-png --enable-freetype-config --without-brotli
make
make install

echo "cleaning up"
cd ..
# rm source dir, but keep tar.gz
[ -d "$D" ] && rm -rf "$D"
