# Installing autoABC 1.0.0

[Back to main README](../README.md)

**Supported target:** OPPO UDP-203 with RU-JB 65-0131, an operational jailbreak overlay, a running compatible `bdpprog.1` and USB AutoScript support. The installer verifies exact code signatures and rejects incompatible environments.

## Before touching the player

1. Confirm the model is an **OPPO UDP-203**. Check firmware under the player's Device Setup > Firmware Information menu; the supported modified environment is **RU-JB 65-0131**, not merely the ordinary official 65-0131 version number.
2. Make and verify your own backup/recovery path for the existing environment. In particular, the jailbreak overlay's `brick_monitor` must work, must not be a symlink, and cannot be an unknown nested third-party wrapper.
3. Stop any playback, eject the disc, and make sure no other mod-installation USB sticks are attached. An incompatible live firmware-code signature causes an intentional abort; do not bypass it.
4. On your computer, verify the downloaded ZIP checksum against the `SHA256SUMS` provided for this release:

```sh
# macOS
shasum -a 256 autoABC-1.0.0-install.zip

# Linux (or macOS with coreutils)
sha256sum autoABC-1.0.0-install.zip
```

Expected SHA-256:

```text
2f57b16aa8b779265c5fe9561cf2a9c1b535837fad2c7fd5cb07109264cafe44
```

## Prepare the USB stick

Use an OPPO-readable USB volume (FAT32 is the conventional AutoScript choice). Extract **only** the installer ZIP directly to its root. The resulting tree includes:

```text
USB_ROOT/
├── AutoScript/
│   ├── AutoScript.TSS
│   ├── autoABC-install.sh
│   ├── autoABC-release.id
│   ├── config.ini
│   └── autoABC/...
├── CHECK_READONLY.sh
└── SHA256SUMS_RELEASE
```

The root must **not** be `USB_ROOT/autoABC-1.0.0-install/AutoScript/`. Do not combine installer and uninstaller folders.

### Select configuration before installation

Open `USB_ROOT/AutoScript/config.ini` in a plain-text editor:

```ini
ISO_BDMV=1
```

Change the value to `0` only if you want automatic region switching for physical Blu-ray Discs but **not** for ISO or BDMV. The option accepts exactly `0` or `1`, one entry, optionally with blank lines or `#` comments. No other keys, duplicates or UTF-8 BOM. This editable file is deliberately excluded from the sealed program-file manifest.

## Install

1. Power the UDP-203 completely off after stopping playback and removing any disc.
2. Insert the prepared USB stick and power the player on.
3. The AutoScript bootstrap finds the complete release on its USB mount, validates the payload and current player, stages the installation and safely preserves the genuine existing early-boot monitor before changing the wrapper.
4. Inspect `autoABC-result.txt` at the USB root. A successful installation contains `INSTALLED`. If `FAILED`, missing, or uncertain, inspect `autoABC.log`; do **not** interpret an optical tray movement as proof of success.
5. Remove the USB stick **before another start**. Fully power-cycle the player.
6. Verify `config.ini`, runtime status and representative physical/media playback tests. See [Verification](VERIFICATION.md).

The installer checks four exact live player instructions **before changing the existing installation**. It also refuses unidentified or ambiguous boot-monitor ownership and unexpected payload hashes. autoABC 1.0.0 is confirmed working by the maintainer. The README-free ZIP keeps every functional file unchanged; its updated archive manifest and new outer packaging have been verified offline.

## Configuration after installation

Installed file: `/mnt/ubi_boot/autoABC/config.ini`. Direct edits are for experts only and require a **full power cycle**. Reinstalling uses the USB `AutoScript/config.ini` as authoritative, even if the installed setting differs.

## Post-install status for SSH/Telnet users

```sh
cat /mnt/ubi_boot/autoABC/config.ini
sh /mnt/ubi_boot/autoABC/config.sh check
sh /mnt/ubi_boot/autoABC/status.sh
/mnt/ubi_boot/autoABC/autoabcctl status
```

The ZIP-root `CHECK_READONLY.sh` is a **post-install** read-only audit; copy it to `/tmp` on the player and run `sh /tmp/CHECK_READONLY.sh`. It does not certify an unknown firmware for installation.

## If anything goes wrong

Do not manually replace `brick_monitor`, alter firmware offsets, mix AutoScript USB sticks or repeatedly attempt to install without reviewing logs. See [Troubleshooting](TROUBLESHOOTING.md) and [Uninstallation](UNINSTALLATION.md).
