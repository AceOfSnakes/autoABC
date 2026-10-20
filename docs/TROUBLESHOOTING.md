# Troubleshooting

## USB install appears to do nothing

Ensure `AutoScript/AutoScript.TSS` is at the root of the USB volume, not inside a nested extraction directory. Try a clean, OPPO-readable USB stick with **only one** package. Check for `autoABC-result.txt` and `autoABC.log` on that same USB. The USB mount point can vary; the installer searches mounted devices and will abort on ambiguous matching installations.

## Result says `FAILED`

Read `autoABC.log` and preserve it after redacting private details. A mismatched player instruction, missing live player, invalid `config.ini`, mismatched runtime checksum, unreadable backup or unknown wrapper are **intentional stops**. Never patch around the error manually.

## There is no uninstall result

Use the separate uninstall archive. Confirm only `AutoScript/AutoScript.TSS` and `autoABC-uninstall.sh` from that archive were extracted. The separate boot command uses MTK-compatible CRLF line endings. Check `/tmp/autoABC-uninstall-error.txt` if SSH/Telnet is available. Avoid manually replacing `brick_monitor`.

## ISO/BDMV still loads despite `ISO_BDMV=0`

This is expected. The switch disables *autoABC's automatic region switching* for these sources, not native ISO/BDMV playback. Verify the installed file and effective mode after a complete power cycle:

```sh
cat /mnt/ubi_boot/autoABC/config.ini
sh /mnt/ubi_boot/autoABC/status.sh
```

If the runtime mode disagrees with the file, power-cycle; simply resuming playback is not enough.

## BD-J region status looks inconsistent

For some BD-J discs, the global region value and PSR20 override are separate. Review `status.sh`, physical-disc logs and PSR20 counters instead of treating one field as definitive. [Technical explanation](research/PHYSICAL_BDJ.md).

## A title is slow to open

Some virtual BD-J titles need both core detection and Java callgraph analysis. Historical sample measurements are approximately 0.9-1.2 seconds of combined detector work, depending on source path; not all discs trigger this sequence. Try `ISO_BDMV=0` if you want the original ISO/BDMV playback behavior. No cache is implemented.

## Report a problem

Include original model, firmware family, source type, `ISO_BDMV` setting, expected and observed behavior, result-file status and appropriately **redacted** logs. Never upload copyrighted disc images, full proprietary firmware or unique device secrets.
