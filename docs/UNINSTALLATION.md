# Removing autoABC

Use the **standalone** `autoABC-1.0.0-uninstall.zip`, not the installer ZIP and not a manual deletion of `/mnt/ubi_boot/autoABC`.

## Uninstall via USB AutoScript

1. Stop playback, eject the disc and fully power down the original UDP-203.
2. Remove any previous `AutoScript/` directory from the USB stick; extract **only** the uninstall ZIP into the USB root.
3. Confirm the root contains `AutoScript/AutoScript.TSS`, `AutoScript/autoABC-uninstall.sh` and `AutoScript/autoABC-uninstall.id`.
4. Insert the USB and start the player from complete power-off.
5. Verify `autoABC-uninstall-result.txt` at the USB root contains **`UNINSTALLED`**. The tray may open as an extra indicator, but that alone is insufficient.
6. Remove the USB and fully power-cycle again.

Expected ZIP SHA-256:

```text
d13fa93bfd10cb21b4afc29bc272864c22a780ad09e767520cdeda5816469dd8
```

## What the uninstaller intends to change

- Refuses symlinks or unfamiliar modifications to its owned early-boot wrapper/backup.
- Verifies a staged copy of the saved original `brick_monitor` before replacing the active wrapper.
- Stops autoABC processes, restores the exact saved original monitor, checks it against its backup, then removes only the autoABC runtime and owned backup/temporary state.
- Leaves unrelated jailbreak overlay content and unrelated mods untouched.
- Does not depend on a functioning `bdpprog.1` player signature, so a broken playback process should not itself block removal.

These are code-intended guarantees backed by offline tests; the **final separate USB uninstaller requires a fresh real-player acceptance run** before public release.

## Failure or no result file

- `FAILED`: read `autoABC-uninstall.log` on USB; **do not force file deletion**.
- No output: check whether `AutoScript/` is at the USB root, that no other installer script is on the same stick, and check `/tmp/autoABC-uninstall-error.txt` via SSH/Telnet if accessible.
- A genuine original `brick_monitor` backup that cannot be verified is a **hard stop**, not an invitation to overwrite it manually.

A separate manual `UNINSTALL.sh` exists at the original installer ZIP root for expert recovery, but it is **not** run by the install AutoScript. Its behavior must be reviewed in the context of the affected device before use.
