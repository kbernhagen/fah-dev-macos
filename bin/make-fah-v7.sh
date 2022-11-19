#!/bin/bash -e

cd "$(dirname "$0")"

. ./env.sh

# unlock keychain if not already unlocked
security unlock-keychain -p fake "$KEYCHAIN" >/dev/null 2>&1 || \
  security unlock-keychain "$KEYCHAIN"

"$FAH_DEV_ROOT"/bin/getclones-v7.sh

export SCONS_OPTIONS="$SCONS_OPTIONS_V7"

echo
echo ======================== fah-control
if [ ! -z "$FAH_CONTROL_HOME" ]; then
  cd "$FAH_CONTROL_HOME"
  scons --clean
  # do not stop build if fah-control build fails
  scons package "$@" || scons -c package && scons -c
fi

echo
echo ======================== fah-control-prebuilt
if [ ! -z "$FAH_CONTROL_PREBUILT_HOME" ]; then
  if [ -d "$FAH_CONTROL_PREBUILT_HOME" ]; then
    cd "$FAH_CONTROL_PREBUILT_HOME"
    if [ ! -d build/pkg/root ]; then
      if [ -f setup.sh ]; then
        ./setup.sh
      fi
    fi
  fi
fi

echo
echo ======================== uninstaller
cd "$FAH_CLIENT_OSX_UNINSTALLER_HOME"
scons package "$@"

echo
echo ======================== cbang
cd "$CBANG_HOME"
scons "$@"
scons test "$@"

echo
echo ======================== fah-viewer
cd "$FAH_VIEWER_HOME"
scons "$@"
scons package "$@"

echo
echo ======================== webclient
cd "$FAH_WEB_CLIENT_HOME"
scons "$@"

echo
echo ======================== libfah
cd "$LIBFAH_HOME"
scons "$@"
scons test "$@"

echo
echo ======================== fah-client
cd "$FAH_CLIENT_HOME"
scons "$@"
scons package "$@"

echo
echo ======================== installer
cd "$FAH_CLIENT_OSX_INSTALLER_HOME"
scons package "$@"

echo
echo "done"
