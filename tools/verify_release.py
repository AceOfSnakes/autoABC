#!/usr/bin/env python3
"""Read-only verifier for the three sealed autoABC 1.1.0 USB ZIPs and source parity.

Run: python3 tools/verify_release.py /path/to/release-assets
This verifies exact published hashes, CRCs, internal manifests and all mirrored
shell/text sources. It does not execute OPPO code or build native ARM binaries.
"""
from __future__ import annotations

from pathlib import Path
import subprocess
import sys

if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("Usage: python3 tools/verify_release.py /path/to/release-assets")
    root = Path(__file__).resolve().parents[1]
    runner = Path(__file__).with_name("sync_release_sources.py")
    raise SystemExit(subprocess.call([sys.executable, str(runner), sys.argv[1], str(root), "--check"]))
