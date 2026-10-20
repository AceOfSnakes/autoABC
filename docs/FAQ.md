# Frequently asked questions

**Does autoABC change my permanent Blu-ray region?**  It operates on the supported player's *runtime* selection and attempts to restore the stock value after the relevant playback session. It does not claim to change the factory DVD region or replace the underlying firmware.

**Is `ISO_BDMV=1` the default?**  Yes. ISO and BDMV automatic detection are on by default and can be turned off with `ISO_BDMV=0`.

**Will disabling ISO/BDMV disable ISO playback?**  No. It disables only autoABC's virtual-media region handling. Ordinary firmware playback availability does not change.

**Why can some BD-J ISOs open more slowly?**  Java callgraph analysis may run after other detectors return an inconclusive result. An observed example took around one second of detector work. It is not a deterministic delay for all discs.

**Does autoABC remember a disc for the next time?**  No. There is no cache or cache option.

**Is every Blu-ray title supported?**  No. Disc logic varies, including custom BD-J region checks and ambiguous multi-region masks. We report tested cases and unknowns separately.

**Can this be used on a UDP-205 or a clone?**  Not with this release. Only the original UDP-203 with the specified RU-JB 65-0131 setup is supported; the installer also checks actual live signatures.

**Is this a public firmware image or a jailbreak installer?**  No. You must already have a suitable jailbroken environment. No full proprietary OPPO firmware image is supplied.

**What if the optical tray opens during install/uninstall?**  That is feedback only; verify the `INSTALLED` / `UNINSTALLED` result file.

**Why is a GitHub source archive different from the release ZIP?**  GitHub creates repository snapshots automatically. autoABC uses distinct USB AutoScript assets; extracting a source snapshot to your OPPO is **not** an installation procedure.
