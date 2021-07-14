#!/bin/bash -e

#  install-python-2.7.18.sh

PY="/Library/Frameworks/Python.framework/Versions/2.7/bin/python2"

[ -f "$PY" ] && exit 0

cd "$(dirname "$0")"
cd ..

if [ -z "$FAH_DEV_ROOT" ]; then
  echo "FAH_DEV_ROOT is not defined; using $PWD"
  export FAH_DEV_ROOT="$PWD"
fi

D="$FAH_DEV_ROOT/build"
mkdir -p "$D"
cd "$D"

if [ ! -f "python-2.7.18-macosx10.9.pkg" ]; then
  ../bin/getdownloads.sh
fi

echo
echo "========================================"
echo "installing python 2.7.18"
echo "sudo installer -pkg python-2.7.18-macosx10.9.pkg -target /"
echo
sudo installer -pkg python-2.7.18-macosx10.9.pkg -target /
hash -r

# get pip certs; do NOT upgrade pip
if [ -f "/usr/local/bin/pip2" ]; then
  echo
  echo "pip2 install certifi"
  pip2 install certifi
fi
