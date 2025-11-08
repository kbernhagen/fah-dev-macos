#!/bin/bash -e
cd "$(dirname "$0")"
source ./env.sh
source ./create-venv.sh

# unlock keychain if not already unlocked
# Note: coretool is currenly not signed
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
cd "$BUILD_ROOT"/core-tools
scons "$@"
echo "cp coretool $HOME/bin"
mkdir -p "$HOME/bin"
cp coretool "$HOME/bin"

echo
echo "done"
