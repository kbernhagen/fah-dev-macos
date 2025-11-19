#!/bin/bash -eu
cd "$(dirname "$0")"
source ./env.sh
mkdir -p "$BUILD_ROOT"
cd "$BUILD_ROOT"
echo
echo "Cloning private repos..."

[[ ! -d libfah ]] && \
echo && \
git clone https://github.com/FoldingAtHome/libfah.git || true

[[ ! -d core-tools ]] && \
echo && \
git clone https://github.com/FoldingAtHome/core-tools.git || true

[[ ! -d gromacs-core ]] && \
echo && \
git clone https://github.com/FoldingAtHome/gromacs-core.git || true
