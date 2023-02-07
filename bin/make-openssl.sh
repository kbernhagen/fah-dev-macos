#!/bin/bash -e

#  make-openssl.sh

if [ -z "$FAH_DEV_ROOT" ]; then
  echo "FAH_DEV_ROOT is not defined"
  exit 1
fi

export SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
export MACOSX_DEPLOYMENT_TARGET=10.7
PFIX="$HOME/fah-local-10.7-universal"

[ -f "$PFIX/lib/libssl.a" ] && exit 0

D="openssl-1.1.1s"
F="$D.tar.gz"

cd "$FAH_DEV_ROOT/build"

[ -d "$D" ] && rm -r "$D"

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

echo "cleaning up"
rm "$PFIX"/bin/openssl-{arm64,x86_64}
rm "$PFIX"/lib/libcrypto.a-{arm64,x86_64}
rm "$PFIX"/lib/libssl.a-{arm64,x86_64}
cd ..
# rm source dir, but keep tar.gz
[ -d "$D" ] && rm -rf "$D"
