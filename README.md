# autoABC

**Automatic Blu-ray Region A / B / C selection for the original OPPO UDP-203.**

`autoABC` is an independent community modification for an **original OPPO UDP-203 running the RU-JB 65-0131 environment**. It examines region restrictions and selects a suitable *runtime* Blu-ray region for supported physical Blu-ray Discs. Automatic selection for Blu-ray ISO images and BDMV folders is included and can be disabled.

> **Release qualification:** The supplied 1.0.0 install and uninstall ZIPs have passed archive, integrity and offline packaging checks. The *final hardened USB installers themselves* still require a documented installation-and-uninstallation acceptance run on the actual player before public release. [Verification status](docs/VERIFICATION.md). The availability of files in this staging repository does not mean hardware sign-off has occurred.

> **Risk:** This is unofficial software. It hooks the live player process and modifies the jailbreak overlay's early-boot launcher (with a guarded backup/restore procedure). An incompatible environment can cause loss of playback or boot problems. Do not install without a working recovery plan.

## What it does

| Media | Automatic Blu-ray region | Configuration |
| --- | --- | --- |
| Physical HDMV Blu-ray | Yes, for supported region checks | Always enabled |
| Physical BD-J Blu-ray | Yes, with BD-J / PSR20 handling | Always enabled |
| Blu-ray ISO | Yes | `ISO_BDMV=1` by default |
| Blu-ray BDMV folder | Yes | `ISO_BDMV=1` by default |

When an automatic region has been selected, the mod aims to return to the configured stock region when the relevant playback session ends. BD-J navigation states are more complicated than ordinary HDMV sessions, and behavior outside tested discs is not guaranteed. This is **not** a DVD region patch, a firmware replacement, or a guarantee that every region-locked disc will work.

## Compatibility

- **Only:** original OPPO UDP-203, RU-JB 65-0131 environment.
- Requires a functioning compatible jailbreak overlay, BusyBox, AutoScript USB startup and the expected running player (`bdpprog.1`).
- Installer checks **four exact live firmware-code signatures** before installing and fails closed if these or ownership checks do not match.
- Other OPPO models, clones, stock firmware, alternate patched players and unfamiliar boot wrappers are **not** supported by this release.

See [compatibility and limitations](docs/COMPATIBILITY.md) before using it.

## Downloads

The release consists of two **separate** USB AutoScript archives:

- `autoABC-1.0.0-install.zip` - install or reinstall; contains the editable configuration file and a read-only status checker.
- `autoABC-1.0.0-uninstall.zip` - restore the guarded original early-boot monitor and remove autoABC.

Use the checksums supplied alongside the release. **Do not mix the two `AutoScript/` directories on a single USB stick.** GitHub's automatically generated source archives are not installer archives.

## Quick installation

1. Confirm your exact supported model and firmware. Make a verified backup and ensure you can recover your player.
2. Stop playback, eject the disc, then extract **only** `autoABC-1.0.0-install.zip` to the root of a clean USB stick. The root must contain `AutoScript/AutoScript.TSS`.
3. If needed, edit `AutoScript/config.ini` to choose `ISO_BDMV=0` or `ISO_BDMV=1` (default). Use plain UTF-8 text without a BOM.
4. Connect the stick and power-cycle the OPPO completely.
5. Check `autoABC-result.txt` at the USB root. Only the result **`INSTALLED`** indicates success; for a failure read `autoABC.log`. A tray-opening signal alone proves nothing.
6. Remove the USB stick and perform another full power cycle before testing.

Full instructions, including checksum verification, troubleshooting, SSH/Telnet status and safe recovery: [Installation](docs/INSTALLATION.md).

## Configuration: ISO and BDMV

```ini
ISO_BDMV=1
```

- `1` (default): automatic selection for physical discs, ISO images and BDMV folders.
- `0`: automatic selection for **physical discs only**. Native ISO/BDMV playback remains available if supported by the player's firmware, but autoABC does not select a region for it.

Disabling the virtual-media branch can avoid a perceptible BD-J detection pause on some ISO/BDMV titles. A historical *Avatar* test measured approximately 0.34 s for an ISO core check and 0.60 s for a fallback Java callgraph, and approximately 0.51 s + 0.71 s for BDMV. These are **individual measurement samples**, not a universal added delay or promised speed improvement. [Timing details](docs/research/VIRTUAL_MEDIA_TIMING.md).

There is **no cache feature or cache setting**. The USB configuration wins on every installation and reinstallation. [Configuration guide](docs/CONFIGURATION.md).

## Check status

After boot, experts using Telnet or SSH can run:

```sh
cat /mnt/ubi_boot/autoABC/config.ini
sh /mnt/ubi_boot/autoABC/config.sh check
sh /mnt/ubi_boot/autoABC/status.sh
/mnt/ubi_boot/autoABC/autoabcctl status
```

The installer ZIP also contains `CHECK_READONLY.sh` at its root. This is a **post-installation** verification tool, not a standalone pre-install firmware compatibility certification. [Verification guide](docs/VERIFICATION.md).

## Uninstall

1. Eject the disc and fully shut down the player.
2. Prepare a **separate** USB stick containing only the extracted `autoABC-1.0.0-uninstall.zip`.
3. Start the player from power-off with that stick inserted.
4. Confirm that the USB root file `autoABC-uninstall-result.txt` says **`UNINSTALLED`**. If not, inspect `autoABC-uninstall.log` and do not force a manual early-boot modification.
5. Remove the USB stick and fully power-cycle again.

Details: [Uninstall and recovery](docs/UNINSTALLATION.md).

## Documentation

- [Installation](docs/INSTALLATION.md) and [Uninstallation](docs/UNINSTALLATION.md)
- [Configuration](docs/CONFIGURATION.md), [Compatibility](docs/COMPATIBILITY.md), [Troubleshooting](docs/TROUBLESHOOTING.md), [FAQ](docs/FAQ.md)
- [Architecture](docs/research/ARCHITECTURE.md) and [Research archive](docs/research/README.md)
- [Verification and hardware acceptance](docs/VERIFICATION.md)
- [Sources and acknowledgments](docs/SOURCES.md); [rights and licensing](docs/LEGAL_AND_LICENSING.md)

## Source code and releases

Original release ZIPs are preserved **byte-for-byte** in the handoff's release-assets directory. This repository publishes the readable shell-side integration for review but does **not** contain the full native ARM/hook-binary build inputs, whose redistribution rights have not been established. `mkrelease.sh` copies and verifies **already sealed input archives**; it does not claim to rebuild their native code from scratch. See [source inventory](src/README.md) and [build limitations](docs/BUILD_AND_PROVENANCE.md).

## Disclaimer

Unofficial project, not affiliated with or endorsed by OPPO Digital. OPPO and UDP-203 product names identify the supported hardware. Use at your own risk. No code license or third-party redistribution license is assumed; review [legal status](docs/LEGAL_AND_LICENSING.md) before any public publication.
