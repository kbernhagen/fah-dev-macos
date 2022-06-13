#!/bin/bash -e

cd "$(dirname "$0")"

. ./env.sh

mkdir -p "$BUILD_ROOT"
cd "$BUILD_ROOT"

echo
echo "Cloning public repos..."

[[ ! -d cbang ]] && \
echo && \
git clone https://github.com/CauldronDevelopmentLLC/cbang.git

[[ ! -d fah-client-osx-uninstaller ]] && \
echo && \
git clone https://github.com/FoldingAtHome/fah-client-osx-uninstaller.git

[[ ! -d fah-client-bastet ]] && \
echo && \
git clone https://github.com/FoldingAtHome/fah-client-bastet.git

[[ ! -d fah-web-client-bastet ]] && \
echo && \
git clone https://github.com/FoldingAtHome/fah-web-client-bastet.git

echo
