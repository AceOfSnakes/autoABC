# Release engineering and integrity

Release 1.0.0 ships **two distinct USB AutoScript archives**. The README is maintained in the GitHub repository and intentionally **not duplicated inside either ZIP**. Both public archives were repacked from the maintainer-supplied functioning 1.0.0 ZIPs with **no changes to their functional members**. The outer `SHA256SUMS_RELEASE` manifest was regenerated because `README.md` was removed. No runtime code, launchers or configuration bytes were changed.

## Installer

- Size: **80,643 bytes**; **52 ZIP entries**; **50/50 outer manifest entries**.
- Includes `AutoScript/AutoScript.TSS`, `AutoScript/autoABC-install.sh`, `AutoScript/config.ini` and required runtime.
- Installs **45 runtime files**: 44 immutable files pinned by a SHA-256 manifest, plus 1 intentionally editable configuration file.
- Nested runtime manifest SHA-256: `bdf2606dcfa93eefd181f0cc7a2310322352825f95f33980c970cadcd9873d7b` (unchanged).
- Validates four exact live player-code signatures, checks its own payload, stages the installation and preserves the existing owned `brick_monitor` before modifying early-boot startup.
- `CHECK_READONLY.sh` is a post-install status and integrity checker; not an additional release or a standalone pre-install compatibility package.

## Uninstaller

- Size: **2,647 bytes**; **4 ZIP entries**; **3/3 outer manifest entries**.
- Includes a separate USB `AutoScript.TSS` with preserved CRLF line endings, a separate uninstaller script and identification marker.
- Checks bootstrap ownership and saved monitor integrity, restores the owned monitor and removes only autoABC-managed files. It does not depend on the running player process being healthy.

## Exact release hashes

```text
2f57b16aa8b779265c5fe9561cf2a9c1b535837fad2c7fd5cb07109264cafe44  autoABC-1.0.0-install.zip
aa15f85d37eac272fbffad3d27800c1efc220657cda794876e25b827836c7862  autoABC-1.0.0-uninstall.zip
```

## Source and reproducibility

The public source tree supplies the readable shell components and offline checker, but **does not include a complete independent native ARM build chain**. `mkrelease.sh` verifies and copies the sealed release ZIPs; it does not compile native binaries. The hook/signature assets in release ZIPs need appropriate rights/provenance review before redistribution.

## Verification scope

The maintainer confirmed autoABC 1.0.0 functionality. This rework performed computer-side ZIP CRC, manifest and byte-equivalence verification on both **README-free** archives; it did **not** conduct a new USB hardware test specifically of the newly repacked outer ZIP envelopes. See [Verification](../VERIFICATION.md) and [Evidence register](EVIDENCE_REGISTER.md).
