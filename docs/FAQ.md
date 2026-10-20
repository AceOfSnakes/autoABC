# Frequently asked questions

**Which player and firmware do I need?**  An **OPPO UDP-203 with RU-JB 65-0131 jailbreak firmware** and working jailbreak overlay. The installer checks specific live code signatures and startup ownership.

**Does autoABC change my permanent Blu-ray region?**  It selects a compatible region during playback and is designed to restore the configured stock state afterward. It does not change the DVD region.

**Are all seven region masks supported?**  Yes, all nonempty A/B/C combinations are implemented. Hardware evidence exists for A, B, A+B and B+C; synthetic tests cover C-only and A+C. No worldwide disc-compatibility guarantee is possible. [Details](REGION_SUPPORT.md).

**Does `ISO_BDMV=1` mean ISO/BDMV auto-region is enabled?**  Yes, that is the default. Change to `ISO_BDMV=0` to turn off only virtual-media automatic region detection.

**Does `ISO_BDMV=0` disable ISO playback?**  No. It leaves the player's ordinary virtual-media playback available and avoids autoABC processing for those sources.

**Why can some BD-J ISOs open more slowly?**  Complex Java callgraph analysis sometimes takes several hundred milliseconds. A measured title needed roughly one second of detector work. It is not a fixed delay. [Measurements](research/VIRTUAL_MEDIA_TIMING.md).

**Does autoABC maintain a per-disc cache?**  No; no cache feature or setting exists in 1.0.0.

**Is this a jailbreak-firmware installation?**  No. The required RU-JB firmware and working overlay must already be installed.

**What if the optical tray opens but there is no result file?**  Tray motion alone does not demonstrate success. Read `autoABC.log` or `autoABC-uninstall.log` and follow [Troubleshooting](TROUBLESHOOTING.md).
