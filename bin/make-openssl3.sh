#!/bin/bash -eu -o pipefail

PFIX="$OPENSSL_HOME"

echo
echo "Building/installing static OpenSSL3 into $PFIX"

if [ -f "$PFIX/lib/libssl.a" ]; then
  echo "\"$PFIX/lib/libssl.a\" already exists"
  exit 0
fi

export SDKROOT=$(xcrun --sdk macosx --show-sdk-path)

V="3.5.2"
D="openssl-${V}"
F="${D}.tar.gz"
URL="https://github.com/openssl/openssl/releases/download/${D}/${F}"
SHA256="c53a47e5e441c930c3928cf7bf6fb00e5d129b630e0aa873b08258656e7345ec"

mkdir -p "$FAH_DEV_ROOT/build"
cd "$FAH_DEV_ROOT/build"

if [ ! -f "$F" ]; then
  echo "downloading $F"
  curl -fLO --remove-on-error "$URL"
fi

echo "verifying sha256"
echo -n "$SHA256  $F" | shasum -a 256 -c || $(rm "$F" && exit 1)

[ -d "$D" ] && rm -rf "$D" || true

echo "extracting $F"
tar xzf "$F"
cd "$D"

# make for x86_64
echo "building openssl for x86_64"
export MACOSX_DEPLOYMENT_TARGET=10.13
./Configure darwin64-x86_64-cc no-shared --prefix="$PFIX"
make -j$SCONS_JOBS
make test
make install
make distclean

mv "$PFIX"/bin/openssl{,-x86_64}
mv "$PFIX"/lib/libcrypto.a{,-x86_64}
mv "$PFIX"/lib/libssl.a{,-x86_64}
mv "$PFIX"/lib/ossl-modules/legacy.dylib{,-x86_64}

set +u
if [ "$1" == "split" ]; then
  mv "$PFIX" "$PFIX"-x86_64
fi
set -u

# make for arm64
# SAME prefix
echo "building openssl for arm64"
export MACOSX_DEPLOYMENT_TARGET=11.0
./Configure darwin64-arm64-cc no-shared --prefix="$PFIX"
make -j$SCONS_JOBS
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

set +u
if [ "$1" == "split" ]; then
  mv "$PFIX" "$PFIX"-arm64
  exit
fi
set -u

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
[ -d "$D" ] && rm -rf "$D" || true
