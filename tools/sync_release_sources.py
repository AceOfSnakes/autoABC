#!/usr/bin/env python3
"""Verify sealed autoABC 1.1.0 USB assets; mirror readable sources, no binary redistribution."""
from __future__ import annotations

import argparse
import hashlib
from pathlib import Path, PurePosixPath
import sys
from zipfile import ZipFile

ASSETS = {
    "CHECKONLY": ("autoABC-1.1.0-CHECKONLY.zip", "d8896b250dd072a86ce8df7ed007e0e980c01deda520df9ec43f6546dfd90b8f"),
    "install": ("autoABC-1.1.0-install.zip", "10ed41939612614cf6d7c8c43f20ddaf0e007ec73eb9a584916c057debd00a2d"),
    "uninstall": ("autoABC-1.1.0-uninstall.zip", "92c8a3bef287a25795739447253654e0db3938badc63314f80bc684f8915f444"),
}

def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()

def check(ok: bool, message: str) -> None:
    if not ok:
        raise ValueError(message)

def validate_manifest(z: ZipFile, manifest: str, prefix: str = "") -> None:
    lines = z.read(manifest).decode("ascii").splitlines()
    members = set(z.namelist()) - {manifest}
    if prefix:
        members = {s[len(prefix):] for s in members if s.startswith(prefix)}
    seen = set()
    for line in lines:
        check(len(line) >= 67 and line[64:66] == "  ", f"bad manifest format: {manifest}")
        digest, name = line[:64], line[66:]
        check(name not in seen and name in members, f"missing or duplicate {name} in {manifest}")
        seen.add(name)
        check(sha(z.read(prefix + name)) == digest, f"bad hash: {name}")
    check(seen == members, f"manifest misses members: {manifest}: {sorted(members-seen)}")

def validate_zip(path: Path, expected: str) -> ZipFile:
    check(path.is_file(), f"missing {path}")
    check(sha(path.read_bytes()) == expected, f"outer SHA-256 differs: {path.name}")
    z = ZipFile(path)
    names = z.namelist()
    check(len(names) == len(set(names)) and not z.testzip(), f"duplicate or CRC issue: {path.name}")
    for name in names:
        parts = PurePosixPath(name).parts
        check(not name.startswith("/") and "\\" not in name and all(p not in ("", ".", "..") for p in parts), f"unsafe member: {name}")
    validate_manifest(z, "SHA256SUMS_RELEASE")
    if "AutoScript/autoABC/SHA256SUMS" in names:
        validate_manifest(z, "AutoScript/autoABC/SHA256SUMS", "AutoScript/autoABC/")
    return z

def planned_files(zips: dict[str, ZipFile], sums: bytes) -> dict[str, bytes]:
    z = zips["install"]
    plan: dict[str, bytes] = {}
    root = "AutoScript/autoABC/"
    runtime = {
        name.removeprefix(root): z.read(name)
        for name in z.namelist()
        if name.startswith(root) and z.read(name).startswith(b"#!/bin/sh")
    }
    check(len(runtime) == 15, f"unexpected runtime shell file count: {len(runtime)}")
    for name, contents in runtime.items():
        check("/" not in name and contents.decode("utf-8"), f"unexpected runtime script {name}")
        plan["src/runtime/" + name] = contents
    expected_installer = {
        "install": {"AutoScript.TSS", "autoABC-install.sh", "autoABC-brick-wrapper.sh", "autoABC-prev-early.sh", "autoABC-prev.sh", "autoABC-release.id", "config.ini", "uopfree.ini"},
        "CHECKONLY": {"AutoScript.TSS", "CHECKONLY", "autoABC-install.sh", "autoABC-brick-wrapper.sh", "autoABC-prev-early.sh", "autoABC-prev.sh", "autoABC-release.id", "config.ini", "uopfree.ini"},
        "uninstall": {"AutoScript.TSS", "autoABC-uninstall.sh", "autoABC-uninstall.id"},
    }
    for mode, items in expected_installer.items():
        zz = zips[mode]
        names = {n.removeprefix("AutoScript/") for n in zz.namelist() if n.startswith("AutoScript/") and "/" not in n.removeprefix("AutoScript/")}
        check(names == items, f"unexpected {mode} entrypoints: {sorted(names ^ items)}")
        for name in sorted(items):
            plan[f"installer/{mode.lower()}/{name}"] = zz.read("AutoScript/" + name)
    plan["docs/research/INSTALLED_PAYLOAD_SHA256SUMS_1.1.0.txt"] = z.read("AutoScript/autoABC/SHA256SUMS")
    plan["docs/research/RELEASE_1.1.0_SHA256SUMS.txt"] = sums
    return plan

def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("assets", type=Path, help="directory with four published v1.1.0 assets")
    ap.add_argument("repo", type=Path, help="repository root")
    ap.add_argument("--check", action="store_true", help="verify source parity without changing files")
    args = ap.parse_args()
    sums = (args.assets / "SHA256SUMS").read_bytes()
    expected_sums = "".join(f"{digest}  {file}\n" for file, digest in ASSETS.values()).encode("ascii")
    check(sums == expected_sums, "published SHA256SUMS mismatch")
    zips = {key: validate_zip(args.assets / filename, digest) for key, (filename, digest) in ASSETS.items()}
    files = planned_files(zips, sums)
    mismatch = []
    for rel, contents in sorted(files.items()):
        target = args.repo / rel
        if args.check:
            if not target.is_file() or target.read_bytes() != contents:
                mismatch.append(rel)
        else:
            if not target.is_file() or target.read_bytes() != contents:
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(contents)
                mismatch.append(rel)
    for z in zips.values():
        z.close()
    if args.check and mismatch:
        raise ValueError(f"source parity FAIL ({len(mismatch)}): {mismatch}")
    print(f"SOURCE_PARITY={'PASS' if args.check else 'SYNCED'} files={len(files)} changes={len(mismatch)} outer_sha=PASS crc=PASS manifests=PASS")

if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError) as exc:
        print(f"SOURCE_SYNC=FAIL: {exc}", file=sys.stderr)
        sys.exit(1)
