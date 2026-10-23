# USB installer source layout — autoABC 1.1.0

- `installer/checkonly/` contains the complete **readable top-level AutoScript files** from v1.1.0 CHECKONLY, including the marker, config and UOPfree INIs.
- `installer/install/` contains the same **readable top-level AutoScript files** from the INSTALL ZIP without the CHECKONLY marker.
- `installer/uninstall/` contains the independent uninstaller `AutoScript.TSS`, `autoABC-uninstall.sh` and version identity file.
- `installer/legacy-v1.0.0/` preserves historical manual and post-install read-only tools from the 1.0.0 source snapshot. These are **not** the supported 1.1.0 CHECKONLY mechanism.

The 1.1.0 files are extracted byte-for-byte by the pinned `tools/sync_release_sources.py`. The `AutoScript.TSS` files are MediaTek scripts (including CRLF) and **must not** be reformatted or treated as POSIX shell.

**These source folders are not complete installer packages:** native ARM binaries, signature/hook payloads and manifests are deliberately not duplicated here. For installation, use the official [v1.1.0 Release ZIPs](https://github.com/DamnFine815/autoABC/releases/tag/v1.1.0), never a ZIP assembled from the source folder.

See [Installation](../docs/INSTALLATION.md) and [Build and provenance](../docs/BUILD_AND_PROVENANCE.md).
