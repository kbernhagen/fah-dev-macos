#!/bin/bash -e
[ -z "$NOTARIZE_PROFILE" ] \
&& echo "error: NOTARIZE_PROFILE is not set" \
&& exit 1

for item in "$@"; do
  echo "xcrun notarytool submit --wait -p \"$NOTARIZE_PROFILE\" \"$item\""
  xcrun notarytool submit --wait -p "$NOTARIZE_PROFILE" "$item"
done
