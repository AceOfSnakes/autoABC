# autoABC

`autoABC` is an independent community modification for **OPPO UDP-203 devices running the RU-JB 65-0131 environment**. It examines region restrictions and selects a suitable *runtime* Blu-ray region (A, B or C) for supported physical Blu-ray Discs. Automatic selection for Blu-ray ISO images and BDMV folders is also included but can be disabled.

> **Risk:** This is unofficial software. It hooks the live player process and modifies the jailbreak overlay's early-boot launcher (with a guarded backup/restore procedure). An incompatible environment can cause loss of playback or boot problems. Do not install without a working recovery plan.

## Features

- Automatic Blu-ray region selection for **HDMV** and **BD-J** discs, including discs that evaluate the player's **PSR20** region.
- Region-aware analysis of single-region, multi-region and unrestricted Blu-ray titles.
- Physical-disc playback support, including tested startup, STOP, HOME, EJECT and replay scenarios.
- Optional support for **ISO and BDMV**, enabled by default (`ISO_BDMV=1`).
- Automatic return toward the configured stock region after the applicable playback session.
- Independent USB **install** and **uninstall** packages, firmware-code signature checks and conservative boot-wrapper handling.
- No persistent disc cache and no need to install a separate companion mod.

## Region support and testing

The region-selection logic implements **all seven nonempty A/B/C allowed-region combinations**. Here, *supported by the detector* and *demonstrated with a physical disc* are deliberately distinguished.

| Blu-ray region type | autoABC detection / selection | Evidence from development |
| --- | --- | --- |
| **A only** | Supported | Physical BD-J disc playback |
| **B only** | Supported | Physical HDMV disc playback |
| **C only** | Supported | Synthetic Java / detector test; no separately documented C-only physical disc |
| **A+B** | Supported | Physical HDMV and BD-J disc playback |
| **A+C** | Supported | Synthetic Java / detector test; no separately documented A+C physical disc |
| **B+C** | Supported | Physical-disc restrictions and ISO/BDMV tests |
| **A+B+C / region-free** | Supported | Unrestricted-region metadata and false-positive test cases |

The aim is broad compatibility with standard Blu-ray region types, including HDMV control-flow checks, BD-J application logic, allowed-region masks and PSR20 queries. **No mod can guarantee that every Blu-ray release worldwide will work**: publisher-specific Java code, authoring variations, unusual region checks and different disc pressings can still require investigation. For example titles and precise test categories, see [Region support](docs/REGION_SUPPORT.md) and [Test evidence](docs/research/TEST_EVIDENCE.md).

Sony documents Blu-ray regions A/B/C and region-free discs; the Blu-ray Disc Association describes region playback control with both HDMV and BD-J formats. See [Sources](docs/SOURCES.md).

## Supported media

| Source | Automatic region selection | Default |
| --- | --- | --- |
| Physical HDMV Blu-ray | Yes | On |
| Physical BD-J Blu-ray | Yes | On |
| Blu-ray ISO | Yes, optional | On |
| Blu-ray BDMV folder | Yes, optional | On |

This is **not** a DVD region patch, an AACS/Cinavia bypass or a promise of universal playback for all discs.

## Requirements

- **OPPO UDP-203 with RU-JB 65-0131 jailbreak firmware** and a functioning compatible jailbreak overlay.
- Working USB AutoScript startup and compatible running player process (`bdpprog.1`).
- Four firmware-code signatures and the current boot-wrapper state must pass the installer's checks. A matching firmware number alone does not bypass these checks.
- A workable backup/recovery procedure is recommended before changing the early-boot configuration.

See [Compatibility](docs/COMPATIBILITY.md).

## Downloads and installation

Download the two **release assets**, not GitHub's automatically generated source snapshot:

- **`autoABC-1.0.0-install.zip`** – installs or reinstalls autoABC; includes `AutoScript/config.ini` and a read-only checker.
- **`autoABC-1.0.0-uninstall.zip`** – removes autoABC and restores its guarded early-boot changes.

The ZIPs have separate internal `SHA256SUMS_RELEASE` manifests. **Never mix the two `AutoScript/` trees on one USB stick.**

1. Check that your player has the required jailbreak firmware and confirm you can recover the current overlay setup.
2. Stop playback, eject any disc and extract **only** the install ZIP to the root of a clean USB stick, so the root contains `AutoScript/AutoScript.TSS`.
3. Leave `AutoScript/config.ini` at the default `ISO_BDMV=1`, or change it to `ISO_BDMV=0` if preferred.
4. Power the player fully off, connect the USB stick and start the player.
5. On the USB stick, verify `autoABC-result.txt` says **`INSTALLED`**. A moving tray by itself does not prove success. Read `autoABC.log` if installation fails.
6. Remove the USB stick and fully power-cycle the player before testing playback.

**Complete guides:** [Installation](docs/INSTALLATION.md) · [Uninstallation](docs/UNINSTALLATION.md) · [Verification](docs/VERIFICATION.md).

## ISO/BDMV configuration

```ini
ISO_BDMV=1
```

- **`1` (default):** autoABC also detects and selects regions for Blu-ray ISO and BDMV folders.
- **`0`:** disables autoABC's virtual-media region selection. Physical Blu-ray auto-region remains enabled; the player's ordinary ISO/BDMV playback facilities are unchanged.

Some complicated BD-J ISO/BDMV titles can take longer to open when automatic detection is enabled. One *Avatar* analysis recorded roughly **0.93 seconds of ISO detector work** and **1.22 seconds of BDMV detector work** along the relevant fallback paths. Those are historical example measurements, **not** guaranteed added loading times. Users who prefer the faster native path for their own media can choose `ISO_BDMV=0`.

More: [Configuration](docs/CONFIGURATION.md) · [Virtual-media timing](docs/research/VIRTUAL_MEDIA_TIMING.md).

## Runtime status

For experienced users with SSH or Telnet after installation:

```sh
cat /mnt/ubi_boot/autoABC/config.ini
sh /mnt/ubi_boot/autoABC/config.sh check
sh /mnt/ubi_boot/autoABC/status.sh
/mnt/ubi_boot/autoABC/autoabcctl status
```

The installer also contains `CHECK_READONLY.sh`, a **post-installation** integrity/status checker.

## Documentation

- [Installation](docs/INSTALLATION.md), [Uninstallation](docs/UNINSTALLATION.md) and [Compatibility](docs/COMPATIBILITY.md)
- [Configuration](docs/CONFIGURATION.md), [FAQ](docs/FAQ.md), [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Blu-ray region support and test matrix](docs/REGION_SUPPORT.md)
- [Technical architecture](docs/research/ARCHITECTURE.md), [Research index](docs/research/README.md) and [Evidence register](docs/research/EVIDENCE_REGISTER.md)
- [Sources and references](docs/SOURCES.md), [Release notes](docs/RELEASE_NOTES_1.0.0.md)

## Code and build scope

The repository includes the **readable shell-side components, AutoScript launchers, tests, offline validation tools and research documentation**. It does not contain a full independent native ARM/hook-binary build chain. The release ZIPs include compiled helpers and firmware-specific hook data; they are not a complete native source build. [Build and provenance](docs/BUILD_AND_PROVENANCE.md) · [Licensing status](docs/LEGAL_AND_LICENSING.md).

## Disclaimer

This independent project is not affiliated with or endorsed by OPPO Digital. Region support is extensive but cannot guarantee successful playback of every Blu-ray title or edition.
