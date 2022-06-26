#!/bin/bash -e

cd "$(dirname "$0")"

source ./env.sh

# unlock keychain if not already unlocked
security unlock-keychain -p fake "$KEYCHAIN" >/dev/null 2>&1 || \
  security unlock-keychain "$KEYCHAIN"

./getclones.sh
./getclones-private.sh

echo
echo ======================== cbang
cd "$CBANG_HOME"
scons "$@"
scons test "$@"

echo
echo ======================== libfah
cd "$LIBFAH_HOME"
scons "$@"
scons test "$@"

echo
echo ======================== core-tools
cd "$LIBFAH_HOME"/../core-tools
scons "$@"
echo "cp coretool $HOME/bin"
mkdir -p $HOME/bin
cp coretool $HOME/bin

echo
echo "done"
