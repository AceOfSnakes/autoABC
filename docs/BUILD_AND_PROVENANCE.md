# Source availability and release provenance

## The distinction

- **Public repository:** English documentation, readable integration shell scripts, read-only diagnostic source, AutoScript launcher source, engineering evidence index and offline verification tools.
- **Sealed release assets:** the two exact archive files supplied by the maintainer, preserving native ARM executables and hook fragments in their original packaged form.
- **Private development sources:** four original conversation documents, historic tests, binary provenance and any restricted inputs not cleared for public redistribution.

Do **not** interpret the source repository as a complete from-scratch build system for every native binary. The full ARM source/toolchain/reproducible build inputs were not supplied in this handoff, and some hook binaries require independent rights checks. The shell files copied under `src/runtime` and `installer` match the release assets byte-for-byte; the repository intentionally omits the unverified binary assets.

## Local sealed-archive build / verification

Put the previously supplied, verified ZIPs on your computer, then run:

```sh
sh mkrelease.sh /path/to/autoABC-1.0.0-install.zip /path/to/autoABC-1.0.0-uninstall.zip
```

This procedure checks the exact two outer SHA-256 identities, expected package layout, CRCs, internal manifests and editable default configuration. It then **copies**, without recompression, both sealed files into `dist/` and writes `dist/SHA256SUMS`.

It does **not** compile native code, change the installed mod or create a new firmware patch. For a true independently reproducible source build, the remaining native-source and asset-provenance gaps must be resolved first.

## Fixed archive identities

```text
c1fdddfcf88e4bebb3d200e58c7724c242c1326ce538cffad128b21067444dff  autoABC-1.0.0-install.zip
d13fa93bfd10cb21b4afc29bc272864c22a780ad09e767520cdeda5816469dd8  autoABC-1.0.0-uninstall.zip
```

No older internal experiment is an accepted substitute for either ZIP. Archives with the same display name but different hashes are **different artifacts** and must not be silently treated as this release.

## Source tree scope

- `src/runtime/`: exactly copied shell-side runtime components; original filenames are intentional API/path names.
- `installer/install/`: exact install script, install AutoScript launcher, and editable config template.
- `installer/uninstall/`: exact separate uninstall script and AutoScript launcher.
- `installer/read-only/`: exact diagnostic checker and separately provided manual recovery helper.
- `docs/research/`: derived, curated English documentation and two internal file-hash manifests.
- `tools/verify_release.py`: offline validator for the sealed archives.

Shell scripts may contain **private compatibility identifiers** that are operationally required by their matching logic. Altering those text markers merely to rename an historical label could break installation or uninstall. These identifiers are not public product names.
