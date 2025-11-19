#!/bin/bash -eu
cd "$(dirname "$0")"
source ./env.sh
source ./create-venv.sh
# unlock keychain if not already unlocked
security unlock-keychain -p fake "$KEYCHAIN" >/dev/null 2>&1 || \
  security unlock-keychain "$KEYCHAIN"
echo
cd "$BUILD_ROOT"
scons -C fah-client-osx-uninstaller package "$@"
echo
echo "done"
