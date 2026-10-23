# autoABC 1.1.0

Automatic Blu-ray Region A/B/C selection for OPPO UDP-203 (RU-JB 65-0131).

### What's new

- Physical HDMV and BD-J/PSR20 auto-region, optional ISO/BDMV detection.
- `EARLYBOOT=1` by default, to improve region selection for an already-inserted disc at startup.
- Integrated [UOPfree](https://github.com/DamnFine815/UOPfree) with `UOPFREE=1` by default (STOP, MENU, NEXT where authored UOP restrictions apply).
- Support for jb_overlay v1.7, v2.0 and v3, oppo-dv-mkv v1.6.0 and supported combined boot chains, subject to CHECKONLY signature checks.
- Improved safe installation and uninstallation, `ALREADY_INSTALLED` detection, logs and bounded EJECT signaling.

### Important: uninstall before upgrading

**Uninstall any older autoABC using that version's matching uninstaller, then fully power-cycle before running 1.1.0 CHECKONLY. Never install 1.1.0 on top of an older build.** Also uninstall standalone [UOPfree](https://github.com/DamnFine815/UOPfree) before enabling integrated `UOPFREE=1`.

### Installation

1. Extract `autoABC-1.1.0-CHECKONLY.zip` alone to a clean USB root. Edit `AutoScript/config.ini` and `AutoScript/uopfree.ini` if required. Boot and confirm `COMPATIBLE` in `autoABC-result.txt`.
2. Extract `autoABC-1.1.0-install.zip` alone to a clean USB root. Set the **same options**, boot, and confirm `INSTALLED` or verified `ALREADY_INSTALLED` in `autoABC-result.txt`.
3. Remove USB and fully power-cycle the player. Check operation using the [README](https://github.com/DamnFine815/autoABC).
4. To remove 1.1.0 use **its matching** `autoABC-1.1.0-uninstall.zip` and reboot.

Tray movement is not proof of success; always check the USB result and log. Read-only CHECKONLY does not guarantee future cold-boot or disc behavior.

### Defaults

`ISO_BDMV=1` (additional ISO/BDMV region analysis; set `0` if opening some BD-J virtual media seems slower), `EARLYBOOT=1`, `UOPFREE=1`.

### Download assets

- `autoABC-1.1.0-CHECKONLY.zip`
- `autoABC-1.1.0-install.zip`
- `autoABC-1.1.0-uninstall.zip`
- `SHA256SUMS` (SHA-256 of exactly the three ZIP files)

### Third-party notice

The installer bundles static ARM BusyBox 1.31.0 with its GPLv2 license notice. [Upstream source](https://busybox.net/downloads/busybox-1.31.0.tar.bz2). The original binary's build configuration has not been recovered.
