# Verification and release integrity

## Playback and functional status

The maintainer has confirmed that **autoABC 1.0.0 works** on the supported OPPO UDP-203 jailbreak environment. Development records also document physical HDMV/BD-J testing, virtual-media use, and region-selection / restoration behavior on representative titles.

The two public release ZIPs were later **repacked only to remove the redundant top-level `README.md`**. Every other payload file — including AutoScript launchers, runtime scripts, native components and the editable config template — is **byte-identical** to the working submitted ZIPs. `SHA256SUMS_RELEASE` is the sole edited retained ZIP member, and it now omits the removed README. These new archive envelopes have passed offline verification; no separate claim is made that the new ZIP envelopes themselves were booted from USB after repacking.

## Archive fingerprints

```text
2f57b16aa8b779265c5fe9561cf2a9c1b535837fad2c7fd5cb07109264cafe44  autoABC-1.0.0-install.zip
aa15f85d37eac272fbffad3d27800c1efc220657cda794876e25b827836c7862  autoABC-1.0.0-uninstall.zip
```

## Verified on a computer for the README-free ZIPs

- Both archive CRC checks and path/symlink safety checks pass.
- The installer has **52 entries** with **50/50** outer manifest hashes; the uninstaller has **4 entries** with **3/3** outer manifest hashes.
- All **44/44** hashed immutable runtime files match the nested manifest. The 45th installed runtime file is the user-editable `config.ini`.
- Default `AutoScript/config.ini` contains exactly `ISO_BDMV=1` and no cache option.
- The AutoScript launchers, `AutoScript.TSS` line endings and all executable payload bytes match the working inputs.
- No `README.md` is present inside either ZIP.
- The repository's source snapshot has been checked against the corresponding packaged shell scripts.

## Optional post-install inspection

After boot, experienced users can use `CHECK_READONLY.sh` from the installer ZIP (a read-only **post-installation** check, not a separate compatibility-check installer):

```sh
sh /tmp/CHECK_READONLY.sh
```

The expected terminal marker is `READONLY_CHECK=PASS`; transfer the file to `/tmp` before running it. The script checks installed hashes, config, status and launcher ownership without installing anything.

## Limits

Offline checks cannot prove that all disc editions will play, or that archive repacking has been re-tested through an actual USB boot. Before publishing binaries, a separate review of redistribution rights for native/hook components is also prudent. Technical playback tests and synthesized region-mask checks are described in [Region support](REGION_SUPPORT.md) and [Test evidence](research/TEST_EVIDENCE.md).
