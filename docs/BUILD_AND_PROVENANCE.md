# Source availability and release provenance

## The distinction

- **Public repository:** English documentation, readable integration shell scripts, read-only diagnostic source, AutoScript launcher source, engineering evidence index and offline verification tools.
- **Sealed release assets:** the two README-free ZIPs derived from the maintainer-supplied 1.0.0 archives, retaining byte-identical functional components.
- **Private development sources:** development reports and lab notes, historic tests, binary provenance and any restricted inputs not cleared for public redistribution.

Do **not** interpret the source repository as a complete from-scratch build system for every native binary. The complete ARM source/toolchain/reproducible build inputs are not present in this public repository, and some hook binaries require independent rights checks. The shell files copied under `src/runtime` and `installer` match the release assets byte-for-byte; the repository intentionally omits the unverified binary assets.

## Release archive verification / assembly

The root `mkrelease.sh` is retained for compatibility. Despite its historical name, it verifies and copies the existing, checksum-pinned archives; it does not compile source code or build native ARM binaries.

## Local sealed-archive build / verification

Put the previously supplied, verified ZIPs on your computer, then run:

```sh
sh mkrelease.sh /path/to/autoABC-1.0.0-install.zip /path/to/autoABC-1.0.0-uninstall.zip
```

This procedure checks the exact two outer SHA-256 identities, expected package layout, CRCs, internal manifests and editable default configuration. It then **copies**, without recompression, both sealed files into `dist/` and writes `dist/SHA256SUMS`.

It does **not** compile native code, change the installed mod or create a new firmware patch. For a true independently reproducible source build, the remaining native-source and asset-provenance gaps must be resolved first.

## Fixed archive identities

```text
2f57b16aa8b779265c5fe9561cf2a9c1b535837fad2c7fd5cb07109264cafe44  autoABC-1.0.0-install.zip
aa15f85d37eac272fbffad3d27800c1efc220657cda794876e25b827836c7862  autoABC-1.0.0-uninstall.zip
```

A ZIP with the same display name but a different hash is a **different artifact**; confirm its identity against the published `SHA256SUMS`.

## Source tree scope

- `src/runtime/`: exactly copied shell-side runtime components; existing runtime filenames are intentional API/path names.
- `installer/install/`: exact install script, install AutoScript launcher, and editable config template.
- `installer/uninstall/`: exact separate uninstall script and AutoScript launcher.
- `installer/read-only/`: exact diagnostic checker and separately provided manual recovery helper.
- `docs/research/`: derived, curated English documentation and two internal file-hash manifests.
- `tools/verify_release.py`: offline validator for the sealed archives.

Shell scripts may contain **private compatibility identifiers** that are operationally required by their matching logic. Altering those text markers merely to rename an historical label could break installation or uninstall. These identifiers are not public product names.
