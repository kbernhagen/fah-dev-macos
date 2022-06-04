#!/bin/bash -e

cd "$(dirname "$0")"

. ./env.sh

mkdir -p "$BUILD_ROOT"
cd "$BUILD_ROOT"

# public
echo
echo "Cloning public repos..."

[[ ! -d cbang ]] && \
echo && \
git clone https://github.com/CauldronDevelopmentLLC/cbang.git

[[ ! -d testHarness ]] && \
echo && \
git clone https://github.com/CauldronDevelopmentLLC/testHarness.git

[[ ! -d fah-client-osx-installer ]] && \
echo && \
git clone https://github.com/FoldingAtHome/fah-client-osx-installer.git

[[ ! -d fah-client-osx-uninstaller ]] && \
echo && \
git clone https://github.com/FoldingAtHome/fah-client-osx-uninstaller.git

[[ ! -d fah-client-version ]] && \
echo && \
git clone https://github.com/FoldingAtHome/fah-client-version.git

[[ ! -d fah-control ]] && \
echo && \
git clone https://github.com/FoldingAtHome/fah-control.git

[[ ! -d fah-web-client ]] && \
echo && \
git clone https://github.com/FoldingAtHome/fah-web-client.git

[[ ! -d containers ]] && \
echo && \
git clone https://github.com/FoldingAtHome/containers.git

[[ ! -d fah-viewer ]] && \
echo && \
git clone https://github.com/FoldingCommunity/fah-viewer.git

[[ ! -d fah-control-gtk3 ]] && \
echo && \
git clone https://github.com/cdberkstresser/fah-control.git fah-control-gtk3

[[ ! -d fah-osx-installer ]] && \
echo && \
git clone https://github.com/kbernhagen/fah-osx-installer.git

[[ ! -d fah-client-bastet ]] && \
echo && \
git clone https://github.com/FoldingAtHome/fah-client-bastet.git

[[ ! -d fah-web-client-bastet ]] && \
echo && \
git clone https://github.com/FoldingAtHome/fah-web-client-bastet.git

echo
