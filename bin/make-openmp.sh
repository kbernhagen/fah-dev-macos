#!/bin/bash -eu -o pipefail
echo
echo "Building/installing static OpenMP into $LIBOMP_HOME"

if ! type cmake &>/dev/null
then
  echo "error: cmake is not installed or not in PATH; cannot build openmp"
  exit 1
fi

export SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
export LIBOMP_PREFIX="$LIBOMP_HOME"

if [ -f "$LIBOMP_PREFIX/lib/libomp.a" ]; then
  echo "\"$LIBOMP_PREFIX/lib/libomp.a\" already exists"
  exit 0
fi

V="14.0.6"
D0="openmp-${V}"
D="openmp-${V}.src"
F="${D}.tar.xz"
URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-$V/$F"
SHA256="4f731ff202add030d9d68d4c6daabd91d3aeed9812e6a5b4968815cfdff0eb1f"

mkdir -p "$FAH_DEV_ROOT/build"
cd "$FAH_DEV_ROOT/build"

if [ ! -f "$F" ]; then
  echo "downloading $F"
  curl -fLO --remove-on-error "$URL"
fi

echo "verifying sha256"
echo -n "$SHA256  $F" | shasum -a 256 -c || $(rm "$F" && exit 1)

[ -d "$D0" ] && rm -rf "$D0" || true
mkdir -p "$D0" && cd "$D0"

echo "extracting $F"
tar xf "../$F"
cd "$D"

uv pip install FileCheck lit
uv pip install not --no-deps

echo
echo "building openmp for x86_64"
export MACOSX_DEPLOYMENT_TARGET=10.15
ctriple="x86_64-apple-darwin"
mkdir -p build && cd build
cmake \
  -DCMAKE_INSTALL_PREFIX="$LIBOMP_PREFIX" \
  -DCMAKE_C_COMPILER_TARGET=$ctriple \
  -DCMAKE_CXX_COMPILER_TARGET=$ctriple \
  -DCMAKE_C_FLAGS="" \
  -DCMAKE_CXX_FLAGS="-faligned-new" \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOSX_DEPLOYMENT_TARGET \
  -DLIBOMP_ENABLE_SHARED=OFF \
  -DLIBOMP_INSTALL_ALIASES=OFF \
  -DCMAKE_OSX_ARCHITECTURES="x86_64" \
  -DCMAKE_SYSTEM_NAME="Darwin" \
  ..
make -j$SCONS_JOBS V=1
make install
cd .. && mv build build-$$-intel
mv "$LIBOMP_PREFIX"/lib/libomp.a{,-x86_64}

echo
echo "building openmp for arm64"
export MACOSX_DEPLOYMENT_TARGET=11.0
ctriple="arm64-apple-darwin"
# SAME prefix
mkdir -p build && cd build
cmake \
  -DCMAKE_INSTALL_PREFIX="$LIBOMP_PREFIX" \
  -DCMAKE_C_COMPILER_TARGET=$ctriple \
  -DCMAKE_CXX_COMPILER_TARGET=$ctriple \
  -DCMAKE_C_FLAGS="" \
  -DCMAKE_CXX_FLAGS="-faligned-new" \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOSX_DEPLOYMENT_TARGET \
  -DLIBOMP_ENABLE_SHARED=OFF \
  -DLIBOMP_INSTALL_ALIASES=OFF \
  -DCMAKE_OSX_ARCHITECTURES="arm64" \
  -DCMAKE_SYSTEM_NAME="Darwin" \
  ..
make -j$SCONS_JOBS V=1
make install
cd .. && mv build build-$$-arm
mv "$LIBOMP_PREFIX"/lib/libomp.a{,-arm64}

echo "creating universal openmp via lipo"
/usr/bin/lipo -create \
 "$LIBOMP_PREFIX"/lib/libomp.a-{arm64,x86_64} \
 -output "$LIBOMP_PREFIX"/lib/libomp.a

echo "cleaning up"
rm "$LIBOMP_PREFIX"/lib/libomp.a-{arm64,x86_64}
cd "$FAH_DEV_ROOT/build"
# rm source dir, but keep archive
[ -d "$D0" ] && rm -rf "$D0" || true
