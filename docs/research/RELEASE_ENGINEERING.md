# Release engineering, install guards and provenance

The final distribution consists of two separately verified USB AutoScript ZIPs. These are the only intended release download assets. **Do not merge, recompress, or silently rebuild either archive** after pinning the exact SHA-256. [D4]

## Installer archive - sealed facts

- Size: **83,806 bytes**; **53 ZIP entries**; CRC passed.
- Includes `AutoScript/AutoScript.TSS` and `AutoScript/autoABC-install.sh` for the MTK launcher.
- Installed runtime contains **45 files**: 44 immutable items specified by `AutoScript/autoABC/SHA256SUMS` and one editable `AutoScript/config.ini` copied to `/mnt/ubi_boot/autoABC/config.ini`.
- The installer verifies the identity of its own runtime manifest and all listed files before changing the device. It rejects unrecognized payloads, invalid config, unexpected code signatures and unsafe boot monitors.
- It reads the running `bdpprog.1` from `/proc/<pid>/mem`, verifying **four exact code signatures** before beginning the installation transaction.
- It stages new runtime files and attempts transaction rollback on failure. It preserves an exact owned original `brick_monitor` backup rather than depending on a single hard-coded monitor hash.
- It uses a guarded wrapper so the ordinary early-boot process still runs through the preserved original.

### Integrity detail

The 44-file runtime manifest itself is SHA-pinned to:

```text
bdf2606dcfa93eefd181f0cc7a2310322352825f95f33980c970cadcd9873d7b
```

`AutoScript/config.ini` is intentionally **not** included in immutable manifests, so users can edit `ISO_BDMV` before installation. No other program code should be modified on the USB. A read-only checker at the ZIP root validates installed hashes and expected processes after boot.

## Uninstall archive - sealed facts

- Size: **3,803 bytes**; **5 ZIP entries**; CRC passed.
- Separate USB `AutoScript.TSS` and `autoABC-uninstall.sh`.
- Intended operation: verify ownership, symlink safety and saved genuine boot monitor; stop autoABC; atomically restore monitor; remove owned runtime and temporary state; write USB result `UNINSTALLED`.
- Does not rely on `bdpprog.1` being operational; that matters if the mod caused playback problems.
- The launcher uses short MTK command lines and CRLF end-of-line characters, because an earlier installer-like uninstall launch gave no visible result on the OPPO and line formatting was a plausible issue.

## File and directory exclusions

The final packaging process rejects or ignores stale runtime helpers, retired binary hook fragments and unwanted Mac metadata (`.DS_Store`, `._*`, `__MACOSX`). It does **not** delete unrelated mod directories in the jailbreak overlay. Legacy owned backup names remain potentially necessary for safe recognition/migration; they must not be renamed without further hardware validation even when product docs use only the autoABC brand.

## Offline vs physical hardware

The final pair was generated and offline verified, but an offline script can only exercise simulated files and state. It cannot prove the real OPPO AutoScript launcher will start or that `brick_monitor` backup and restoration are sound on the actual device. Previous software revisions provided live playback evidence, not direct certification of this final release pair.

**Release gate:** Do not mark 1.0.0 as fully ready for public download until a recorded live install, uninstall and recovery acceptance run is complete **and** all redistribution rights are established. These are distinct requirements.

## Reproducibility limits

The public-source draft contains the runtime shell scripts and bootstrap sources, but neither native ARM compilation sources nor all redistributable hook binaries. `mkrelease.sh` verifies and copies the fixed sealed assets; it is a byte-preserving release assembly **from existing trusted ZIPs**, not an independent source-to-binary build. See [Build and provenance](../BUILD_AND_PROVENANCE.md) and [Legal](../LEGAL_AND_LICENSING.md).
