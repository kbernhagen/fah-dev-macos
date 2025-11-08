#!/bin/bash -e
# make-openssl3.sh
cd "$(dirname "$0")"
source ./env.sh

if [ -z "$FAH_DEV_ROOT" ]; then
  echo "FAH_DEV_ROOT is not defined"
  exit 1
fi

export SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
export MACOSX_DEPLOYMENT_TARGET=10.7
PFIX="$HOME/fah-local-10.7-universal"

[ -f "$PFIX/lib/libssl.a" ] && exit 0

V="3.5.2"
D="openssl-${V}"
F="${D}.tar.gz"
URL="https://github.com/openssl/openssl/releases/download/${D}/${F}"
SHA256="c53a47e5e441c930c3928cf7bf6fb00e5d129b630e0aa873b08258656e7345ec"

cd "$FAH_DEV_ROOT/build"

[ ! -f "$F" ] && curl -fsSLO "$URL"

echo -n "$SHA256  $F" | shasum -a 256 -c || $(rm "$F" && exit 1)

[ -d "$D" ] && rm -rf "$D"

echo "extracting $F"
tar xzf "$F"
cd "$D"

# make for x86_64
echo "building openssl for x86_64"
./Configure darwin64-x86_64-cc no-shared --prefix="$PFIX"
make
make test
make install
make distclean

mv "$PFIX"/bin/openssl{,-x86_64}
mv "$PFIX"/lib/libcrypto.a{,-x86_64}
mv "$PFIX"/lib/libssl.a{,-x86_64}
mv "$PFIX"/lib/ossl-modules/legacy.dylib{,-x86_64}

if [ "$1" == "split" ]; then
  mv "$PFIX" "$PFIX"-x86_64
fi

# make for arm64
export MACOSX_DEPLOYMENT_TARGET=11.0
# SAME prefix
echo "building openssl for arm64"
./Configure darwin64-arm64-cc no-shared --prefix="$PFIX"
make
# can only test on arm
if [ "$(uname -m)" == "arm64" ]; then
  make test
fi
make install
make distclean

mv "$PFIX"/bin/openssl{,-arm64}
mv "$PFIX"/lib/libcrypto.a{,-arm64}
mv "$PFIX"/lib/libssl.a{,-arm64}
mv "$PFIX"/lib/ossl-modules/legacy.dylib{,-arm64}

if [ "$1" == "split" ]; then
  mv "$PFIX" "$PFIX"-arm64
  exit
fi

# lipo universal
echo "creating universal openssl via lipo"
/usr/bin/lipo -create \
 "$PFIX"/bin/openssl-{arm64,x86_64} \
 -output "$PFIX"/bin/openssl

/usr/bin/lipo -create \
 "$PFIX"/lib/libcrypto.a-{arm64,x86_64} \
 -output "$PFIX"/lib/libcrypto.a

/usr/bin/lipo -create \
 "$PFIX"/lib/libssl.a-{arm64,x86_64} \
 -output "$PFIX"/lib/libssl.a

/usr/bin/lipo -create \
 "$PFIX"/lib/ossl-modules/legacy.dylib-{arm64,x86_64} \
 -output "$PFIX"/lib/ossl-modules/legacy.dylib

echo "cleaning up"
rm "$PFIX"/bin/openssl-{arm64,x86_64}
rm "$PFIX"/lib/libcrypto.a-{arm64,x86_64}
rm "$PFIX"/lib/libssl.a-{arm64,x86_64}
rm "$PFIX"/lib/ossl-modules/legacy.dylib-{arm64,x86_64}
cd ..
# rm source dir, but keep tar.gz
[ -d "$D" ] && rm -rf "$D"
