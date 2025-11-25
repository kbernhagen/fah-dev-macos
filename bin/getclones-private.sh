#!/bin/bash -eu
cd "$(dirname "$0")"
mkdir -p "$BUILD_ROOT"
cd "$BUILD_ROOT"
echo
echo "Cloning private repos into $BUILD_ROOT"
for repo in libfah core-tools gromacs-core
do
    if [ -d "$repo" ]; then
        echo "skipping existing $repo"
    else
        echo
        git clone git@github.com:FoldingAtHome/$repo.git
    fi
done
