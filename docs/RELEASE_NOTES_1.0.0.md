# autoABC 1.0.0 - proposed release notes

**Automatic Blu-ray region A/B/C selection for the original OPPO UDP-203 on RU-JB 65-0131.**

This release supports physical HDMV and BD-J Blu-ray region selection, with separately configurable ISO and BDMV support. **`ISO_BDMV=1` is the default**; use `ISO_BDMV=0` if you prefer not to run automatic region detection for ISO/BDMV playback. Some BD-J virtual media may take longer to initialize while the region is analyzed. The mod has no cache.

### Download files

- `autoABC-1.0.0-install.zip` - standalone USB AutoScript installation or update.
- `autoABC-1.0.0-uninstall.zip` - separate USB AutoScript removal and boot-monitor restoration.
- `SHA256SUMS` - authenticates the byte identities of these two ZIPs.

Extract the selected ZIP **to USB root** with `AutoScript/` directly under that root. **Never mix both packages on one stick.** Installation reports success in `autoABC-result.txt` with `INSTALLED`; uninstall reports `autoABC-uninstall-result.txt` with `UNINSTALLED`. Remove USB and perform a full power cycle after either operation. See README for complete instructions and restrictions.

**Compatibility:** Original OPPO UDP-203 with supported RU-JB 65-0131 environment and four matching live code signatures only. No claim for stock firmware, UDP-205, clones or unrelated firmware modifications. Runtime hooks and early-boot changes are at your own risk.

**Publication notice (remove only after actual sign-off):** Final sealed packages have passed offline validation, but live-device final USB install/uninstall acceptance and redistribution-rights clearance remain pending. Do not describe this as a fully hardware-certified public release until those items are resolved.
