#!/bin/bash -eu
cd "$(dirname "$0")"
source ./env.sh
mkdir -p "$BUILD_ROOT"
cd "$BUILD_ROOT"
echo
echo "Cloning public repos..."

[[ ! -d cbang ]] && \
echo && \
git clone https://github.com/CauldronDevelopmentLLC/cbang.git || true

[[ ! -d fah-client-osx-uninstaller ]] && \
echo && \
git clone https://github.com/FoldingAtHome/fah-client-osx-uninstaller.git || true

[[ ! -d fah-client-bastet ]] && \
echo && \
git clone https://github.com/FoldingAtHome/fah-client-bastet.git || true

[[ ! -d fah-web-client-bastet ]] && \
echo && \
git clone https://github.com/FoldingAtHome/fah-web-client-bastet.git || true
