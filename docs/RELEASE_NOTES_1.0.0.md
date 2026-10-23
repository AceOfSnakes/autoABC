# autoABC 1.0.0 - Release Notes
# OUTDATED — PLEASE DO NOT USE

> **Historical compatibility:** autoABC 1.0.0 was intended **only for the verified jb_overlay v1.7 environment**. It does not include the 1.1.0 support for jb_overlay V2/V3 or oppo-dv-mkv. To upgrade, uninstall it with its matching 1.0.0 uninstaller, reboot, then run 1.1.0 CHECKONLY.

Automatic Blu-ray Region **A/B/C** selection for the **OPPO UDP-203 with RU-JB 65-0131 jailbreak firmware**.

## Highlights

- Physical **HDMV and BD-J** Blu-ray region selection, including PSR20-aware BD-J handling.
- **All seven A/B/C region combinations** represented by the detection/selection logic; live and synthetic coverage documented separately in the [region-support matrix](https://github.com/DamnFine815/autoABC/blob/main/docs/REGION_SUPPORT.md).
- Optional ISO and BDMV automatic region selection, with **`ISO_BDMV=1` enabled by default**. Set `ISO_BDMV=0` to avoid optional BD-J virtual-media detection delays while retaining physical-disc auto-region.
- Playback-session region handling, safe restoration, conservative detection and no persistent disc cache.
- Firmware signature checks, independent AutoScript install/uninstall packages and an included read-only status checker.

## Release downloads

- [autoABC-1.0.0-install.zip](https://github.com/DamnFine815/autoABC/releases/download/v1.0.0/autoABC-1.0.0-install.zip) — USB installer / reinstaller.
- [autoABC-1.0.0-uninstall.zip](https://github.com/DamnFine815/autoABC/releases/download/v1.0.0/autoABC-1.0.0-uninstall.zip) — USB uninstaller.
- [SHA256SUMS](https://github.com/DamnFine815/autoABC/releases/download/v1.0.0/SHA256SUMS) — SHA-256 fingerprints for both archives.

Extract one ZIP to a clean USB root with `AutoScript/` directly at the root. Never combine installer and uninstaller contents on one stick. See the [README](https://github.com/DamnFine815/autoABC/blob/main/README.md) and [Installation](https://github.com/DamnFine815/autoABC/blob/main/docs/INSTALLATION.md).

## Compatibility and limitations

Requires the stated jailbreak firmware and successful live signature/boot-wrapper checks. All standard region types are addressed by the implementation, but playback of every Blu-ray pressing worldwide is **not guaranteed**. C-only and A+C have synthetic rather than separately documented physical-disc evidence. autoABC does not alter DVD region coding or bypass copy protection.

The maintainer has confirmed autoABC 1.0.0 functionality. The published USB archives preserve byte-identical functional payloads and passed offline integrity checks; the exact published archive envelopes were not separately re-tested on hardware. See [Verification](https://github.com/DamnFine815/autoABC/blob/main/docs/VERIFICATION.md).
