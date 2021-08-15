
# FAH_DEV_ROOT/bin/env.sh
# for developer manual build

HERE="$PWD"

if [ ! -f "./env.sh" ]; then
  echo "error: env.sh needs to be sourced as ./env.sh"
else

# ASSUME we are ALWAYS sourced from fah-dev-root/bin
# ". ./env.sh"
cd ..
export FAH_DEV_ROOT="$PWD"
cd "$HERE"

unset MACOSX_DEPLOYMENT_TARGET

# use latest sdk; we expect 11.1 with Xcode 12.4
# sdk 11 allows cross compiling on macos 10.15+, Xcode 12.2+
# this could be in slavename/slave.sh, or ~/.zprofile
export SDKROOT=$(xcrun --sdk macosx --show-sdk-path)

# use macports python with py2gtk2, even if not in PATH
# this could be in slavename/dockbot.json env
# this can be simply "python" if the first python in path
# is the one with py2app and py2gtk2
export RUN_DISTUTILS="/opt/local/bin/python"

NCPU=$(sysctl -n hw.ncpu)
[ $NCPU -gt 16 ] && NCPU=16
[[ "$(uname -m)" = "arm64" ]] && NCPU=4
export SCONS_JOBS=$NCPU

export BUILD_ROOT="$FAH_DEV_ROOT/workarea"
export PREBUILT_ROOT="$FAH_DEV_ROOT/prebuilt"


B="$FAH_DEV_ROOT/etc/scons-options"
export SCONS_OPTIONS_INTEL="$B.py"
export SCONS_OPTIONS_UNIV="$B-univ.py"
if [ -f "$B-$USER.py" ]; then
  export SCONS_OPTIONS_INTEL="$B-$USER.py"
fi
if [ -f "$B-univ-$USER.py" ]; then
  export SCONS_OPTIONS_UNIV="$B-univ-$USER.py"
fi
# note that univ build requires patched cbang CPUID, libfah CPUIDTool
export SCONS_OPTIONS="$SCONS_OPTIONS_INTEL"


# the keychain to unlock before build starts
# for most ppl, login.keychain is correct
KEYCHAIN="login.keychain"
if [[ "$USER" = "buildbot" ]]; then
  KEYCHAIN="developer.keychain"
fi
# FIXME ugly and does not handle python u'whatever' strings
if [[ -f "$SCONS_OPTIONS" ]]; then
  eval KEY2=$(echo `grep '^ *sign_keychain *=' "$SCONS_OPTIONS" |tail -n 1 |cut -d= -f2`)
  [[ ! -z "$KEY2" ]] && KEYCHAIN="$KEY2"
fi
export KEYCHAIN


# configure install prefix for openssl, freetype, fftw
export OTHER_ROOT_INTEL="$HOME/fah-local-10.7-x86_64"
export OTHER_ROOT_ARM="$HOME/fah-local-11.0-arm64"
export OTHER_ROOT_UNIV="$HOME/fah-local-10.7-universal"
# best to use universal for all targets, unless univ is missing some libs
export OTHER_ROOT="$OTHER_ROOT_UNIV"

export FREETYPE2_HOME="$OTHER_ROOT"
export OPENSSL_HOME="$OTHER_ROOT"

export PATH="$FREETYPE2_HOME/bin:$PATH"

export CBANG_HOME="$BUILD_ROOT/cbang"
export FAH_CLIENT_HOME="$BUILD_ROOT/fah-client"
export FAH_CLIENT_OSX_INSTALLER_HOME="$BUILD_ROOT/fah-client-osx-installer"
export FAH_CLIENT_OSX_UNINSTALLER_HOME="$BUILD_ROOT/fah-client-osx-uninstaller"
export FAH_CLIENT_VERSION_HOME="$BUILD_ROOT/fah-client-version"

export FAH_CONTROL_HOME="$BUILD_ROOT/fah-control"
# fallback if unable to build fah-control on this machine
export FAH_CONTROL_PREBUILT_HOME="$PREBUILT_ROOT/fah-control-prebuilt"
# note fahcontrol may get relocated when installing locally

export FAH_VIEWER_HOME="$BUILD_ROOT/fah-viewer"
export FAH_WEB_CLIENT_HOME="$BUILD_ROOT/fah-web-client"
export LIBFAH_HOME="$BUILD_ROOT/libfah"

fi