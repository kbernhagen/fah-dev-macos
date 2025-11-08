#!/bin/bash -e
cd "$(dirname "$0")"
source ./env.sh
source ./create-venv.sh
# unlock keychain if not already unlocked
security unlock-keychain -p fake "$KEYCHAIN" >/dev/null 2>&1 || \
  security unlock-keychain "$KEYCHAIN"
echo
echo ======================== uninstaller
cd "$FAH_CLIENT_OSX_UNINSTALLER_HOME"
scons package "$@"
echo
echo "done"
