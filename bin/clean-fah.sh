#!/bin/bash
cd "$(dirname "$0")"
source ./env.sh
source ./create-venv.sh

cd "$CBANG_HOME" && scons --clean
cd "$LIBFAH_HOME" && scons --clean
cd "$FAH_CLIENT_BASTET_HOME" && scons -c dist && scons -c package && scons -c
cd "$FAH_WEB_CLIENT_BASTET_HOME" && scons -c distclean
cd "$FAH_CLIENT_OSX_UNINSTALLER_HOME" && scons -c package
echo
echo "Removing cruft"
find "$BUILD_ROOT" -name .sconsign.dblite -print -delete
find "$FAH_CLIENT_BASTET_HOME" -type f -name .DS_Store -print -delete
echo
echo "Done cleaning"
