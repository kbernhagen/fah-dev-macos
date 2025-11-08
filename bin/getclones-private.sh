#!/bin/bash -e
cd "$(dirname "$0")"
source ./env.sh
mkdir -p "$BUILD_ROOT"
cd "$BUILD_ROOT"
echo
echo "Cloning private repos..."

[[ ! -d libfah ]] && \
echo && \
git clone https://github.com/FoldingAtHome/libfah.git

[[ ! -d core-tools ]] && \
echo && \
git clone https://github.com/FoldingAtHome/core-tools.git

[[ ! -d gromacs-core ]] && \
echo && \
git clone https://github.com/FoldingAtHome/gromacs-core.git
