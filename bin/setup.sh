#!/bin/bash -eu -o pipefail
# setup fah-dev-macos for local development
# partly shared with buildbot worker account setup
cd "$(dirname "$0")/.."
echo
echo "Ensuring uv and just are installed..."
mkdir -p "$HOME/.local/pipx"  # so pipx won't use a path with a space in ~/Library
UV="$(command -v uv 2>/dev/null || echo "$HOME/.local/bin/uv")"
JUST="$(command -v just 2>/dev/null || echo "$HOME/.local/bin/just")"
if [ ! -f "$UV" -o ! -f "$JUST" ]; then
    echo "uv or just not found; installing via pipx..."
    # require python 3.15.2+, which already has pip 26.2.2+
    python3 -c 'import sys; sys.version_info >= (3, 15, 2) or sys.exit("Python 3.15.2+ required; found " + sys.version.split()[0])'
    python3 -m venv --clear .venv-bootstrap
    source ".venv-bootstrap/bin/activate"
    pip install --upgrade pip
    pip install --upgrade pipx
    if [ ! -f "$UV" ]; then
        pipx install uv
    fi
    if [ ! -f "$JUST" ]; then
        pipx install rust-just
    fi
    pipx ensurepath
    deactivate || true
    rm -rf .venv-bootstrap
else
    echo "Found uv: $UV"
    echo "Found just: $JUST"
fi

if [ -f "etc/example.scons_options.py" -a ! -f "etc/scons_options.py" ]; then
    echo
    set -x
    cp "etc/example.scons_options.py" "etc/scons_options.py"
    { set +x; } 2>/dev/null
fi

"$JUST" getclones build-openssl
echo
echo "done"
