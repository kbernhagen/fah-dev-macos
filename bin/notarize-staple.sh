#!/bin/bash -e
[ -z "$NOTARIZE_PROFILE" ] \
&& echo "error: NOTARIZE_PROFILE is not set" \
&& exit 1

for item in "$@"; do
  echo
  [ -d "$item" ] && echo "ignoring directory $item" && continue
  [ ! -f "$item" ] && echo "ignoring nonexistent file $item" && continue
  [[ ! $item =~ .*\.(pkg|zip|dmg)$ ]] && echo "ignoring $item" && continue
  echo "xcrun notarytool submit --wait -p \"$NOTARIZE_PROFILE\" \"$item\""
  err=0
  xcrun notarytool submit --wait -p "$NOTARIZE_PROFILE" "$item" || err=1
  [ "$err" = "1" ] && echo "error: unable to notarize \"$item\"" && continue
  # FIXME: notarytool Invalid result still exits with 0
  # TODO: capture xml plist output and check result via plistbuddy
  # summission log can show warnings even on Success
  echo
  echo "xcrun stapler staple \"$item\""
  xcrun stapler staple "$item" || echo "error: unable to staple \"$item\""
done
echo
