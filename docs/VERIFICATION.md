# Verification and acceptance status

This page distinguishes **what has been checked on a computer** from **what still needs confirmation on an original player**.

## Verified offline for the sealed 1.0.0 archives

- Installer and uninstaller archive SHA-256 values match the nominated final sources.
- ZIP CRC verification, safe member paths, declared file counts and internal per-file manifests pass.
- All 44 installed immutable runtime files match their manifest; user-editable `config.ini` is the 45th installed file and is excluded by design.
- Install AutoScript and uninstall AutoScript launch files are separate; uninstaller MTK command lines retain CRLF.
- Default installer config is `ISO_BDMV=1`, with no cache setting.
- Shell scripts are present; static parser checks are recorded in the separate handoff QA report.
- Original distribution ZIP bytes are unchanged by this GitHub handoff.

Offline verification cannot demonstrate that the player's USB AutoScript executes, a proprietary firmware process matches at boot time, or an early-boot restoration truly works on hardware.

## Not yet documented as passed on the **final hardened USB archives**

- Install the exact sealed ZIP from USB on the target original UDP-203 and observe `INSTALLED`.
- Full boot after removing the installer USB; status and read-only checker pass.
- Physical BD-J and HDMV playback, STOP/HOME/EJECT and replay on representative discs.
- Virtual ISO/BDMV playback with `ISO_BDMV=1` and unaffected native virtual playback with `ISO_BDMV=0`.
- The uninstaller USB starts and reports `UNINSTALLED`, with exact `brick_monitor` restoration and no collateral damage.
- Reinstall after uninstall; repeat installation and config updates without wrapper nesting.

Prior development demonstrated relevant playback functions on the original hardware. Those checks **do not** automatically sign off the new final installer/uninstaller ZIP pair.

## Post-install read-only check

Copy `CHECK_READONLY.sh` from the install ZIP root to `/tmp/CHECK_READONLY.sh` on the OPPO and execute:

```sh
sh /tmp/CHECK_READONLY.sh
```

It reads on-device checksums, mode, expected processes and bootstrap ownership. Expected terminal status: `READONLY_CHECK=PASS`. It is not an installer, not an uninstalled-device preflight and not universal firmware certification.

## Release criteria

Publish only when the project owner has (1) verified redistribution rights for every release asset and (2) recorded the final-device acceptance run. The private GitHub handoff also supplies a separately maintained hardware acceptance checklist; it is not a public repository file.
