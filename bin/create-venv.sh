#!/bin/bash -e
VENV="$HOME/.venvs/fah-dev-macos"

if [ -f "$VENV/bin/activate" ]; then
  source "$VENV/bin/activate"
else
  echo "Creating $VENV"
  python3 -m venv "$VENV"
  source "$VENV/bin/activate"
  pip3 install --upgrade pip
  pip3 install scons six
fi
