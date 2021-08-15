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


# try install python 2.7.18 pkg
# allow user to not authorize sudo
"$FAH_DEV_ROOT"/bin/install-python-2.7.18.sh || true
hash -r


if [ ! -f "/usr/local/bin/pip2" ]; then

  echo
  echo "========================================"
  echo "/usr/local/bin/pip2 not found"
  echo "unable to install scons, twisted, buildbot"
  echo

else

  # install scons
  if [ ! -f "$HOME/Library/Python/2.7/bin/scons" ]; then
    echo
    echo "========================================"
    echo "installing scons..."
    echo "pip2 install scons --user"
    echo
    pip2 install scons --user
  fi

  # install twisted
  if [ ! -f "$HOME/Library/Python/2.7/bin/twistd" ]; then
    # buildbot requires a python2-compatible twisted
    # if not preinstalled, the buildbot install may grab a py3 twisted
    echo
    echo "========================================"
    echo "installing twisted..."
    echo "pip2 install PyHamcrest==1.10.1 --user"
    echo "pip2 install idna --user"
    echo "pip2 install twisted --user"
    echo
    pip2 install PyHamcrest==1.10.1 --user
    pip2 install idna --user || true
    pip2 install twisted --user
  fi

  # install buildbot 0.7.10p2-jcoffland
  if [ ! -f "$HOME/Library/Python/2.7/bin/buildbot" ]; then
    echo
    echo "========================================"
    echo "installing buildbot..."
    echo "cd $FAH_DEV_ROOT/workarea/buildbot"
    cd "$FAH_DEV_ROOT"/workarea/buildbot
    echo "python2 setup.py install --user"
    echo
    python2 setup.py install --user
  fi

fi


# don't assume py 3.8
PY3VMINOR="`python3 --version | cut -d. -f2`"
PY3V="3.$PY3VMINOR"

# install dockbot; do not use pip
if [ ! -f "$HOME/Library/Python/$PY3V/bin/dockbot" ]; then
  echo
  echo "========================================"
  echo "installing dockbot..."
  echo "cd $FAH_DEV_ROOT/workarea/dockbot"
  cd "$FAH_DEV_ROOT"/workarea/dockbot
  echo "python3 setup.py install --user"
  echo
  python3 setup.py install --user
fi


echo
echo "done"
echo "Note: Do NOT upgrade pip2, despite messages you may see."
echo "It will become incompatible with python2."
echo "Ignore deprecation warnings for python 2.7"
echo
echo "You might want to append the following to .zprofile"
echo
echo "export PY2USERBIN=\"\$HOME/Library/Python/2.7/bin\""
echo "export PY3USERBIN=\"\$HOME/Library/Python/$PY3V/bin\""
echo "export PATH=\"\$PY2USERBIN:\$PY3USERBIN:\$PATH\""
echo "export PATH=\"\$HOME/fah-local-10.7-universal/bin:\$PATH\""
echo "export SDKROOT=\$(xcrun --sdk macosx --show-sdk-path)"
echo
