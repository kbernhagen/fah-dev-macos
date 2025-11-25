#!/bin/bash -eu -o pipefail
# setup fah-dev-macos for local development
# partly shared with buildbot worker account setup
cd "$(dirname "$0")"
cd ..
export FAH_DEV_ROOT="$PWD"

echo
echo "Creating directories in $PWD"
set -x
mkdir -p build workarea
{ set +x; } 2>/dev/null

B="./etc"
if [ -f "$B/example.scons_options.py" -a ! -f "$B/scons_options.py" ]
then
    set -x
    cp "$B/example.scons_options.py" "$B/scons_options.py"
    { set +x; } 2>/dev/null
fi

echo
echo "Ensuring uv and just are installed"
install_venv_pipx() {
    if [ -f ".venv/bin/activate" ]; then
        source ".venv/bin/activate"
    else
        echo "Creating virtual environment..."
        python3 -m venv .venv
        source ".venv/bin/activate"
    fi
    python3 -m pip install --upgrade pipx
}
UV="$(command -v uv 2>/dev/null || echo "$HOME/.local/bin/uv")"
JUST="$(command -v just 2>/dev/null || echo "$HOME/.local/bin/just")"
if [ ! -f "$UV" -o ! -f "$JUST" ]; then
    echo "uv or just not found, installing via pipx..."
    install_venv_pipx
    if [ ! -f "$UV" ]; then
        pipx install uv
        "$UV" tool update-shell
    fi
    if [ ! -f "$JUST" ]; then
        pipx install rust-just
    fi
    deactivate || true
    rm -rf .vemv
else
    echo "Found uv: $UV"
    echo "Found just: $JUST"
fi

"$JUST" getclones

# make libs as needed
# delete existing libs to force rebuild
"$JUST" build-fftw build-openssl

echo
echo "done"
