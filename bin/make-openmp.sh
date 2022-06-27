#!/bin/bash -e

#  make-openmp.sh

# TODO run in virtualenv so python is python3
# TODO find/install llvm-lit for auto testing of build
# Please put llvm-lit in your PATH, set OPENMP_LLVM_LIT_EXECUTABLE to its full path, or point OPENMP_LLVM_TOOLS_DIR to its directory.

cd "$(dirname "$0")"

source ./env.sh

if ! type cmake &>/dev/null
then
  echo "error: cmake is not installed or not in PATH"
  exit 1
fi

export SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
export LIBOMP_PREFIX="$HOME/fah-local-openmp"
export CXXFLAGS="-faligned-new"

if [ -f "$LIBOMP_PREFIX/lib/libomp.a" ]; then
  echo "\"$LIBOMP_PREFIX/lib/libomp.a\" already exists"
  exit 0
fi

V="14.0.5"
D0="openmp-${V}"
D="openmp-${V}.src"
F="${D}.tar.xz"
URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-$V/$F"
SHA256="1f74ede110ce1e2dc02fc163b04c4ce20dd49351407426e53292adbd4af6fdab"

cd "$FAH_DEV_ROOT/build"

[ ! -f "$F" ] && curl -fsSLO "$URL"

echo -n "$SHA256  $F" | shasum -a 256 -c || $(rm "$F" && exit 1)

mkdir -p "$D0" && cd "$D0"
[ -d "$D" ] && rm -r "$D"
[ -d cmake ] && rm -r cmake

echo "extracting $F"
tar xf "../$F"
cd "$D"

echo
echo "building openmp for x86_64"
export MACOSX_DEPLOYMENT_TARGET=10.14
ctriple="x86_64-apple-darwin"
mkdir -p build && cd build
cmake \
  -DCMAKE_INSTALL_PREFIX="$LIBOMP_PREFIX" \
  -DCMAKE_C_COMPILER_TARGET=$ctriple \
  -DCMAKE_CXX_COMPILER_TARGET=$ctriple \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOSX_DEPLOYMENT_TARGET \
  -DLIBOMP_ENABLE_SHARED=OFF \
  -DLIBOMP_INSTALL_ALIASES=OFF \
  ..
make -j V=1
make install
cd .. && rm -r build
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
  -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOSX_DEPLOYMENT_TARGET \
  -DLIBOMP_ENABLE_SHARED=OFF \
  -DLIBOMP_INSTALL_ALIASES=OFF \
  ..
make -j V=1
make install
cd .. && rm -r build
mv "$LIBOMP_PREFIX"/lib/libomp.a{,-arm64}


echo "creating universal openmp via lipo"
/usr/bin/lipo -create \
 "$LIBOMP_PREFIX"/lib/libomp.a-{arm64,x86_64} \
 -output "$LIBOMP_PREFIX"/lib/libomp.a


echo "cleaning up"
rm "$LIBOMP_PREFIX"/lib/libomp.a-{arm64,x86_64}
cd "$FAH_DEV_ROOT/build"
# rm source dir, but keep archive
[ -d "$D0" ] && rm -rf "$D0"
