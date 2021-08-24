#!/bin/bash -e

cd "$(dirname "$0")"

. ./env.sh

# unlock keychain if not already unlocked
security unlock-keychain -p fake "$KEYCHAIN" >/dev/null 2>&1 || \
  security unlock-keychain "$KEYCHAIN"

echo
echo ======================== uninstaller
cd "$FAH_CLIENT_OSX_UNINSTALLER_HOME"
scons

echo
echo ======================== cbang
cd "$CBANG_HOME"
scons

echo
echo ======================== fah-client-bastet
cd "$FAH_CLIENT_BASTET_HOME" && scons && scons package || true

echo
echo ======================== bastet installer
cd "$FAH_CLIENT_BASTET_OSX_INSTALLER_HOME" && scons

echo
echo "done"
