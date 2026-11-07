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

# co-authored by copilot
echo
echo "Checking certificate store..."
CERT_CHECK_STATUS=0
CERT_CHECK_OUTPUT="$(
    {
        openssl crl2pkcs7 -nocrl -certfile /etc/ssl/cert.pem |
            openssl pkcs7 -print_certs -noout |
            grep -E 'emSign ECC Root CA - G3|AAA Certificate Services'
    } 2>&1
)" || CERT_CHECK_STATUS=$?
if [ "$CERT_CHECK_STATUS" -eq 0 ] || [ -n "$CERT_CHECK_OUTPUT" ]; then
    echo "ERROR: Compromised certificates found or certificate check failed:"
    printf '%s\n' "$CERT_CHECK_OUTPUT"
    echo "See instructions at https://support.apple.com/en-us/1495550"
    exit 1
fi
echo OK: no compromised certificates found
echo

"$JUST" getclones build-openssl
echo
echo "done"
