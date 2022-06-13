#!/bin/bash -e

# setup.sh
# setup fah-dev-macos for local development
# partly shared with buildbot account setup


cd "$(dirname "$0")"
cd ..
export FAH_DEV_ROOT="$PWD"

# disable pip version warning
export PIP_DISABLE_PIP_VERSION_CHECK=1

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
#  "$HOME"/fah-local-10.7-x86_64
#  "$HOME"/fah-local-11.0-arm64


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


if [ -f "/usr/local/bin/pip2" ]; then
  # uninstall old scons
  if [ -f "$HOME/Library/Python/2.7/bin/scons" ]; then
    echo
    echo "========================================"
    echo "uninstalling old python2 scons..."
    echo "pip2 uninstall --yes scons"
    echo
    echo "Note: Do NOT upgrade pip2, despite messages you may see."
    echo "It will become incompatible with python2."
    echo "Ignore deprecation warnings for python 2.7"
    echo
    pip2 uninstall --yes scons
  fi
fi

# don't assume py 3.8
PY3VMINOR="`python3 --version | cut -d. -f2`"
PY3V="3.$PY3VMINOR"

echo
echo "========================================"
echo "pip3 install pip --user --upgrade"
pip3 install pip --user --upgrade

if [ ! -f "$HOME/Library/Python/$PY3V/bin/scons" ]; then
  echo
  echo "========================================"
  echo "pip3 install scons --user"
  echo
  pip3 install scons --user
fi

if [ ! -f "$HOME/Library/Python/$PY3V/bin/virtualenv" ]; then
  echo
  echo "========================================"
  echo "pip3 install virtualenv --user"
  echo
  pip3 install virtualenv --user
fi

# six is used by cbang test
echo
echo "========================================"
echo "pip3 install six --user --upgrade"
pip3 install six --user --upgrade

echo
echo "done"
echo
echo "You might want to append the following to .zprofile"
echo
echo "export PY3USERBIN=\"\$HOME/Library/Python/$PY3V/bin\""
echo "export PATH=\"\$PY3USERBIN:\$PATH\""
echo "export PATH=\"\$HOME/fah-local-10.7-universal/bin:\$PATH\""
echo "export SDKROOT=\$(xcrun --sdk macosx --show-sdk-path)"
echo
