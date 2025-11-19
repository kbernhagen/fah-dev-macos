#!/bin/bash -eu
cd "$(dirname "$0")"
source ./env.sh
source ./create-venv.sh

# unlock keychain if not already unlocked
security unlock-keychain -p fake "$KEYCHAIN" >/dev/null 2>&1 || \
  security unlock-keychain "$KEYCHAIN"

cd "$BUILD_ROOT"

echo
echo ======================== fah-web-client-bastet
scons -C fah-web-client-bastet dist "$@" || true

echo
echo ======================== cbang
scons -C cbang "$@"
scons -C cbang test "$@"

echo
echo ======================== fah-client-bastet
scons -C fah-client-bastet "$@"
scons -C fah-client-bastet dist "$@"
scons -C fah-client-bastet package "$@"

echo
echo "done"
