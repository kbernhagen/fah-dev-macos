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

mkdir -p build prebuilt workarea


# copy example.scons-options to scons-options-USER.py
B="./etc"

[ -f "$B/example.scons-options.py" ] && \
[ ! -f "$B/scons-options-$USER.py" ] && \
cp -p "$B/example.scons-options.py" "$B/scons-options-$USER.py"

[ -f "$B/example.scons-options-univ.py" ] && \
[ ! -f "$B/scons-options-univ-$USER.py" ] && \
cp -p "$B/example.scons-options-univ.py" "$B/scons-options-univ-$USER.py"


# get git clones
./bin/getclones.sh

# make static libs
./bin/make-libraries-v8.sh

./bin/create-venv.sh

echo
echo "========================================"
echo "build OpenMP"
if $(type cmake &>/dev/null)
then
  ./bin/make-openmp.sh
else
  echo "Unable to build OpenMP because cmake was not found."
  echo "OpenMP is only needed for building fah cores."
fi

echo
echo "done"
echo
