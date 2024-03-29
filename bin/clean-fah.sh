#!/bin/bash

cd "$(dirname "$0")"

source ./env.sh
source ./create-venv.sh

cd "$CBANG_HOME" && scons --clean
cd "$LIBFAH_HOME" && scons --clean
cd "$FAH_VIEWER_HOME" && scons -c package && scons -c
cd "$FAH_CLIENT_HOME" && scons -c package && scons -c
cd "$FAH_CLIENT_BASTET_HOME" && scons -c dist && scons -c package && scons -c
cd "$FAH_WEB_CLIENT_BASTET_HOME" && scons -c distclean
cd "$FAH_CONTROL_HOME" && scons -c package && scons -c
[ ! -z "$FAH_CONTROL_PREBUILT_HOME" ] && cd "$FAH_CONTROL_PREBUILT_HOME" \
  && [ -f clean.sh ] && ./clean.sh

cd "$FAH_WEB_CLIENT_HOME" && scons --clean || true # partly fails
rm -r "$FAH_WEB_CLIENT_HOME"/resources.{cpp,data,o}
rm -r "$FAH_WEB_CLIENT_HOME"/libfah-web-client-resources.a

cd "$FAH_CLIENT_OSX_UNINSTALLER_HOME" && scons -c package

cd "$FAH_CLIENT_OSX_INSTALLER_HOME" && scons -c package

cd "$FAH_CLIENT_VERSION_HOME" && rm config/fah-client-version/__init__.pyc
cd "$FAH_CLIENT_VERSION_HOME" && rm -r config/fah-client-version/__pycache__

# these are missed by scons --clean
# other *.app instances interfere with install; cause app relocation
rm -rf "$FAH_CONTROL_HOME/build"
rm -rf "$FAH_VIEWER_HOME/FAHViewer.app"

# always leftover; py3 scons ones are not compatible with py2 scons
echo
echo "Removing cruft"
find "$BUILD_ROOT" -name .sconsign.dblite -print -delete
find "$FAH_CLIENT_BASTET_HOME" -type f -name .DS_Store -print -delete

echo
echo "Done cleaning"
