# This file must be used with "source ./env.sh" *from bash*
# you cannot run it directly

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script: \$ source $0" >&2
    exit 33
fi

# FAH_DEV_ROOT/bin/env.sh
# ASSUME we are ALWAYS sourced from fah-dev-root/bin
# "source ./env.sh"
if [ ! -f "./env.sh" ]; then
  echo "error: env.sh needs to be sourced as ./env.sh"
  exit 1
fi
HERE="$PWD"
cd ..
export FAH_DEV_ROOT="$PWD"
cd "$HERE"

unset MACOSX_DEPLOYMENT_TARGET

# use latest sdk; we expect 11.1 with Xcode 12.4
# sdk 11 allows cross compiling on macos 10.15+, Xcode 12.2+
export SDKROOT=$(xcrun --sdk macosx --show-sdk-path)

NCPU=$(sysctl -n hw.ncpu)
if [[ "$(uname -m)" = "arm64" ]]; then
  NN=$(sysctl -n hw.perflevel0.logicalcpu) || NN=$(($NCPU / 2))
  NCPU=$NN
fi
export SCONS_JOBS=$NCPU

B="$FAH_DEV_ROOT/etc/scons-options"
export SCONS_OPTIONS="$B-univ.py"
if [ -f "$B-univ-$USER.py" ]; then
  export SCONS_OPTIONS="$B-univ-$USER.py"
fi

# the keychain to unlock before build starts
KEYCHAIN="login.keychain"
if [[ -f "$SCONS_OPTIONS" ]]; then
  KEY2=$("$FAH_DEV_ROOT/bin/scons_options_keychain.py")
  [[ ! -z "$KEY2" ]] && KEYCHAIN="$KEY2"
fi
export KEYCHAIN

export BUILD_ROOT="$FAH_DEV_ROOT/workarea"

# prefix for static libs openssl, fftw
export OTHER_ROOT="$HOME/fah-local-10.13"

export OPENSSL_HOME="$OTHER_ROOT"
export CBANG_HOME="$BUILD_ROOT/cbang"
export FAH_CLIENT_BASTET_HOME="$BUILD_ROOT/fah-client-bastet"
export FAH_WEB_CLIENT_BASTET_HOME="$BUILD_ROOT/fah-web-client-bastet"
export FAH_CLIENT_OSX_UNINSTALLER_HOME="$BUILD_ROOT/fah-client-osx-uninstaller"
export LIBFAH_HOME="$BUILD_ROOT/libfah"
