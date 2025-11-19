#!/bin/bash -eu
cd "$(dirname "$0")"
source ./env.sh
source ./create-venv.sh

# unlock keychain if not already unlocked
# Note: coretool is currenly not signed
security unlock-keychain -p fake "$KEYCHAIN" >/dev/null 2>&1 || \
  security unlock-keychain "$KEYCHAIN"

./getclones.sh
./getclones-private.sh

cd "$BUILD_ROOT"

echo
echo ======================== cbang
scons -C cbang "$@"
scons -C cbang test "$@"

echo
echo ======================== libfah
scons -C libfah "$@"
scons -C libfah test "$@"

echo
echo ======================== core-tools
scons -C core-tools "$@"
echo "cp coretool $HOME/bin"
mkdir -p "$HOME/bin"
cp coretool "$HOME/bin"

echo
echo "done"
