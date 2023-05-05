#!/bin/bash -e

# setup.sh
# setup fah-dev-macos for local development
# partly shared with buildbot account setup


cd "$(dirname "$0")"
cd ..
export FAH_DEV_ROOT="$PWD"

# TODO
# sanity checks
# check git ssh configured
# check git user.name
# select git clone uses ssh/https
# inform what will be done
# get user confirmation before proceeding


echo
echo "Creating directories"

mkdir -p \
  "$FAH_DEV_ROOT"/{build,prebuilt,workarea} \
  "$HOME"/fah-local-10.7-universal


# do this after any rsync, which may also chmod
chmod 0700 "$FAH_DEV_ROOT"


# copy example.scons-options to scons-options-USER.py
B="$FAH_DEV_ROOT/etc"

[ -f "$B/example.scons-options.py" ] && \
[ ! -f "$B/scons-options-$USER.py" ] && \
cp -p "$B/example.scons-options.py" "$B/scons-options-$USER.py"

[ -f "$B/example.scons-options-univ.py" ] && \
[ ! -f "$B/scons-options-univ-$USER.py" ] && \
cp -p "$B/example.scons-options-univ.py" "$B/scons-options-univ-$USER.py"


# get git clones
"$FAH_DEV_ROOT"/bin/getclones.sh


# get downloads, make static libs
"$FAH_DEV_ROOT"/bin/make-libraries.sh

export PY3USERBIN="$(python3 -m site --user-base)/bin"
export PATH="$PY3USERBIN:$PATH"
hash -r

# six is used by cbang test
echo
echo "========================================"
echo "pip3 install --user --upgrade pip six scons"
pip3 install --user --upgrade pip six scons

echo
echo "========================================"
echo "build OpenMP"
if $(type cmake &>/dev/null)
then
  "$FAH_DEV_ROOT"/bin/make-openmp.sh
else
  echo "Unable to build OpenMP because cmake was not found."
  echo "OpenMP is only needed for building fah cores."
fi

echo
echo "done"
echo
echo "You might want to append the following to .zprofile"
echo
echo "export SDKROOT=\$(xcrun --sdk macosx --show-sdk-path)"
echo "export PY3USERBIN=\"\$(python3 -m site --user-base)/bin\""
echo "export PATH=\"\$PY3USERBIN:\$PATH\""
echo "export PATH=\"\$HOME/fah-local-10.7-universal/bin:\$PATH\""
echo "export PATH=\"\$PATH:\$HOME/bin\""
echo
