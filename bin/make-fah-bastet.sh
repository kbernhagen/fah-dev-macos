#!/bin/bash -e

cd "$(dirname "$0")"

source ./env.sh
source ./create-venv.sh

# unlock keychain if not already unlocked
security unlock-keychain -p fake "$KEYCHAIN" >/dev/null 2>&1 || \
  security unlock-keychain "$KEYCHAIN"

echo
echo ======================== fah-web-client-bastet
cd "$FAH_WEB_CLIENT_BASTET_HOME"
scons dist "$@" || true

echo
echo ======================== cbang
cd "$CBANG_HOME"
scons "$@"
scons test "$@"

echo
echo ======================== fah-client-bastet
cd "$FAH_CLIENT_BASTET_HOME"
scons "$@"
scons dist "$@"
scons package "$@"

echo
echo "done"
