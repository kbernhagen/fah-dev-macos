#!/bin/bash -eu
# setup.sh
# setup fah-dev-macos for local development
# partly shared with buildbot worker account setup
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
mkdir -p build workarea

# copy example.scons-options to scons-options-USER.py
B="./etc"

[ -f "$B/example.scons-options-univ.py" ] && \
[ ! -f "$B/scons-options-univ-$USER.py" ] && \
cp -p "$B/example.scons-options-univ.py" "$B/scons-options-univ-$USER.py"

./bin/getclones.sh
./bin/make-libraries-v8.sh
echo
echo "done"
