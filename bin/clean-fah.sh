#!/bin/bash

cd "$(dirname "$0")"

. ./env.sh

cd "$CBANG_HOME" && scons --clean
cd "$LIBFAH_HOME" && scons --clean
cd "$FAH_VIEWER_HOME" && scons -c package && scons -c
cd "$FAH_CLIENT_HOME" && scons -c package && scons -c
cd "$FAH_CLIENT_BASTET_HOME" && scons -c dist && scons -c package && scons -c
cd "$FAH_CONTROL_HOME" && scons -c package && scons -c

cd "$FAH_WEB_CLIENT_HOME" && scons --clean || true # partly fails
rm -r "$FAH_WEB_CLIENT_HOME"/resources.{cpp,data,o}
rm -r "$FAH_WEB_CLIENT_HOME"/libfah-web-client-resources.a

cd "$FAH_CLIENT_OSX_UNINSTALLER_HOME" && scons --clean

# don't delete final dist packages and zip files
cd "$FAH_CLIENT_OSX_INSTALLER_HOME" && scons --clean

#cd "$FAH_CLIENT_VERSION_HOME"; scons --clean # no SConstruct
rm "$FAH_CLIENT_VERSION_HOME"/config/fah-client-version/__init__.pyc

# these are missed by scons --clean
# other *.app instances interfere with install; cause app relocation
rm -rf "$FAH_CONTROL_HOME/build"
rm -rf "$FAH_VIEWER_HOME/FAHViewer.app"

# always leftover; py3 scons ones are not compatible with py2 scons
echo
echo "Removing scons cruft"
find "$BUILD_ROOT" -name .sconsign.dblite -print -delete

echo
echo "Done cleaning"
