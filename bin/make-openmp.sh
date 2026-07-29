#!/bin/bash -eu -o pipefail

if ! type cmake &>/dev/null
then
  echo "error: cmake is not installed or not in PATH; cannot build openmp"
  exit 1
fi

export LIBOMP_PREFIX="$LIBOMP_HOME"

LTO=
set +u
if [ "$1" == "lto" ]; then
  LIBOMP_PREFIX="$LIBOMP_PREFIX"-lto
  LTO="-flto"
fi
set -u

echo
echo "Building/installing static OpenMP into $LIBOMP_HOME"

if [ -f "$LIBOMP_PREFIX/lib/libomp.a" ]; then
  echo "\"$LIBOMP_PREFIX/lib/libomp.a\" already exists"
  exit 0
fi

export SDKROOT=$(xcrun --sdk macosx --show-sdk-path)

V="17.0.6"
D0="llvm-project-${V}"
D="llvm-project-${V}.src"
F="${D}.tar.xz"
URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-$V/$F"
SHA256="58a8818c60e6627064f312dbf46c02d9949956558340938b71cf731ad8bc0813"

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
hash -r

echo
echo "building openmp static universal library"
export MACOSX_DEPLOYMENT_TARGET=10.15
mkdir -p build && cd build
cmake ../runtimes \
  -G "Unix Makefiles" \
  -DCMAKE_INSTALL_PREFIX="$LIBOMP_PREFIX" \
  -DCMAKE_BUILD_TYPE=Release \
  -DPACKAGE_VERSION="$V" \
  -DLLVM_ENABLE_RUNTIMES=openmp \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_CXX_COMPILER=clang++ \
  -DCMAKE_C_FLAGS="$LTO" \
  -DCMAKE_CXX_FLAGS="-faligned-new $LTO" \
  -DCMAKE_LDFLAGS="$LTO" \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOSX_DEPLOYMENT_TARGET \
  -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
  -DLIBOMP_ENABLE_SHARED=OFF \
  -DLIBOMP_INSTALL_ALIASES=OFF \
  -DLIBOMP_OMPT_SUPPORT=OFF \
  -DCMAKE_SYSTEM_NAME="Darwin"
make -j$SCONS_JOBS V=1
make install

echo "cleaning up"
cd "$FAH_DEV_ROOT/build"
# rm source dir, but keep archive
[ -d "$D0" ] && rm -rf "$D0" || true
