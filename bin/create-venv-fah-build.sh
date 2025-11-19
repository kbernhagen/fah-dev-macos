#!/bin/bash -eu
VENV="$HOME/.venvs/fah-build"

if [ -f "$VENV/bin/activate" ]; then
  source "$VENV/bin/activate"
else
  echo "Creating $VENV"
  python3 -m venv "$VENV"
  source "$VENV/bin/activate"
  pip3 install --upgrade pip
  pip3 install buildbot-worker six scons
  pip3 install "buildbot[tls]" buildbot-www buildbot-waterfall-view \
    buildbot-console-view buildbot-wsgi_dashboards boto3
fi
