#!/bin/sh
# Assemble only known sealed byte-identical autoABC 1.0.0 archives.
# This is NOT a native ARM source-to-binary build.
set -eu
if [ "$#" -ne 2 ]; then
  echo 'Usage: sh mkrelease.sh path/to/autoABC-1.0.0-install.zip path/to/autoABC-1.0.0-uninstall.zip' >&2
  exit 2
fi
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
python3 "$ROOT/tools/verify_release.py" "$1" "$2"
mkdir -p "$ROOT/dist"
cp "$1" "$ROOT/dist/autoABC-1.0.0-install.zip"
cp "$2" "$ROOT/dist/autoABC-1.0.0-uninstall.zip"
python3 - "$ROOT/dist" <<'PYMAKE'
from pathlib import Path
import hashlib,sys
out=Path(sys.argv[1])
lines=[]
for n in ('autoABC-1.0.0-install.zip','autoABC-1.0.0-uninstall.zip'):
 p=out/n
 lines.append(hashlib.sha256(p.read_bytes()).hexdigest()+'  '+n+'\n')
(out/'SHA256SUMS').write_text(''.join(lines),encoding='ascii')
print('Sealed archive copies verified in:',out)
PYMAKE
