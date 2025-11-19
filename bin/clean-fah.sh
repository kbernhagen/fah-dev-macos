#!/bin/bash -u
cd "$(dirname "$0")"
source ./env.sh
source ./create-venv.sh

cd "$BUILD_ROOT" || exit 1

scons -C cbang --clean
scons -C libfah -c
d="fah-client-bastet"
scons -C "$d" -c dist && scons -C "$d" -c package && scons -C "$d" -c
scons -C fah-web-client-bastet -c distclean
scons -C fah-client-osx-uninstaller -c package
echo
echo "Removing cruft"
find "$BUILD_ROOT" -name .sconsign.dblite -print -delete
find "$BUILD_ROOT" -type f -name .DS_Store -print -delete
echo
echo "Done cleaning"
