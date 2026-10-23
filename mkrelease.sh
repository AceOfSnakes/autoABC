#!/bin/sh
# Verify and copy already published autoABC 1.1.0 USB packages; no native build.
set -eu
if [ "$#" -ne 1 ]; then
  echo "Usage: sh mkrelease.sh /path/to/release-assets-directory" >&2
  exit 2
fi
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
python3 "$ROOT/tools/verify_release.py" "$1"
mkdir -p "$ROOT/dist"
for name in autoABC-1.1.0-CHECKONLY.zip autoABC-1.1.0-install.zip autoABC-1.1.0-uninstall.zip SHA256SUMS; do
  cp "$1/$name" "$ROOT/dist/$name"
done
(cd "$ROOT/dist" && sha256sum -c SHA256SUMS)
echo "VERIFIED_COPIES_READY in $ROOT/dist"
