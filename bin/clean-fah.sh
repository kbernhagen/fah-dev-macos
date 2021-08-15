#!/bin/bash

cd "$(dirname "$0")"

. ./env.sh

cd "$CBANG_HOME"; scons --clean
cd "$LIBFAH_HOME"; scons --clean
cd "$FAH_VIEWER_HOME"; scons --clean
cd "$FAH_CLIENT_HOME"; scons --clean

if [ "$FAH_CONTROL_HOME" != "" ]; then
  cd "$FAH_CONTROL_HOME"; scons --clean
fi

#cd "$FAH_WEB_CLIENT_HOME"; scons --clean # fails
rm -r "$FAH_WEB_CLIENT_HOME"/resources.{cpp,data,o}
rm -r "$FAH_WEB_CLIENT_HOME"/libfah-web-client-resources.a

cd "$FAH_CLIENT_OSX_UNINSTALLER_HOME"; scons --clean distclean
cd "$FAH_CLIENT_OSX_INSTALLER_HOME"; scons --clean #distclean

#cd "$FAH_CLIENT_VERSION_HOME"; scons --clean # no SConstruct
rm "$FAH_CLIENT_VERSION_HOME"/config/fah-client-version/__init__.pyc

# these are missed by scons --clean
# other *.app instances interfere with install; cause app relocation
if [ "$FAH_CONTROL_HOME" != "" ]; then
  rm -rf "$FAH_CONTROL_HOME/build"
fi
rm -rf "$FAH_VIEWER_HOME/FAHViewer.app"
