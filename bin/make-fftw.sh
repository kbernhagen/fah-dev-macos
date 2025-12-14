#!/bin/bash -eu -o pipefail

PFIX="$FFTW3_HOME"

LTO=
set +u
if [ "$1" == "lto" ]; then
  PFIX="$PFIX"-lto
  LTO="-flto"
fi
set -u

echo
echo "Building/installing static FFTW3 into $PFIX"

if [ -f "$PFIX/lib/libfftw3f.a" ]; then
  echo "\"$PFIX/lib/libfftw3f.a\" already exists"
  exit 0
fi

export SDKROOT=$(xcrun --sdk macosx --show-sdk-path)

F="fftw-3.3.10.tar.gz"
D="fftw-3.3.10"
URL="https://www.fftw.org/$F"
SHA256="56c932549852cddcfafdab3820b0200c7742675be92179e59e6215b340e26467"

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
export MACOSX_DEPLOYMENT_TARGET=10.13
if [ ! -f "$PFIX/lib/libfftw3f.a" ]; then
  echo "building fftw for x86_64"

  # joseph had --enable-single
  # is --enable-single the same as --enable-float ?
  # these flags are used by dmitry
  # prefix and CFLAGS added by kevin for cross compile
  # configure needs to be run under arch -x86_64 for cross compile
  # on arm64 host with macOS 26
  arch -x86_64 ./configure --host=x86_64-apple-darwin \
    --prefix="$PFIX" \
    CFLAGS="-arch x86_64 $LTO" \
    LDFLAGS="$LTO" \
    --disable-alloca --with-our-malloc16 \
    --disable-shared --enable-static \
    --enable-threads --with-combined-threads \
    --with-incoming-stack-boundary=2 --enable-float \
    --enable-sse2 --enable-avx --enable-avx2

  make -j$SCONS_JOBS
  make check
  make install
  make distclean
  mv "$PFIX"/bin/fftwf-wisdom{,-x86_64}
  mv "$PFIX"/lib/libfftw3f.a{,-x86_64}
fi

# make for arm64
export MACOSX_DEPLOYMENT_TARGET=11.0
if [ ! -f "$PFIX/lib/libfftw3f.a" ]; then
  echo "building fftw for arm64"

  ./configure --host=aarch64-apple-darwin \
    --prefix="$PFIX" \
    CFLAGS="-arch arm64 $LTO" \
    LDFLAGS="$LTO" \
    --disable-alloca --with-our-malloc16 \
    --disable-shared --enable-static \
    --enable-threads --with-combined-threads \
    --with-incoming-stack-boundary=2 --enable-float \
    --enable-neon

  make -j$SCONS_JOBS
  if [ "$(uname -m)" == "arm64" ]; then
    make check
  fi
  make install
  make distclean
  mv "$PFIX"/bin/fftwf-wisdom{,-arm64}
  mv "$PFIX"/lib/libfftw3f.a{,-arm64}
fi

# lipo universal
echo "creating universal fftw via lipo"
/usr/bin/lipo -create \
 "$PFIX"/bin/fftwf-wisdom-{arm64,x86_64} \
 -output "$PFIX"/bin/fftwf-wisdom

/usr/bin/lipo -create \
 "$PFIX"/lib/libfftw3f.a-{arm64,x86_64} \
 -output "$PFIX"/lib/libfftw3f.a

echo "cleaning up"
rm "$PFIX"/bin/fftwf-wisdom-{arm64,x86_64}
rm "$PFIX"/lib/libfftw3f.a-{arm64,x86_64}
cd ..
# rm source dir, but keep tar.gz
[ -d "$D" ] && rm -rf "$D" || true
