# Configuration

`autoABC 1.0.0` has **one** user setting. The default is:

```ini
ISO_BDMV=1
```

| Value | Physical Blu-ray | Blu-ray ISO / BDMV |
| --- | --- | --- |
| `ISO_BDMV=1` (default) | Automatic region selection enabled | Automatic region selection enabled |
| `ISO_BDMV=0` | Automatic region selection enabled | Automatic selection disabled; native firmware playback unaffected |

The switch **does not** unlock every region-coded ISO/BDMV. `0` avoids autoABC's virtual media analysis; it can make certain BD-J ISO/BDMV opens feel faster when their region detection would take perceptible time. Do not advertise a universal fixed time saving. [Measured samples](research/VIRTUAL_MEDIA_TIMING.md).

Edit `AutoScript/config.ini` on the **installer USB** before installation. The parser accepts exactly one `ISO_BDMV=0` or `ISO_BDMV=1`, optional blank lines and `#` comments; invalid values, duplicate keys, other options or BOM cause a safe rejection. No text is evaluated as shell code.

The USB file is copied into `/mnt/ubi_boot/autoABC/config.ini` on every install/reinstall. A manually edited installed copy takes effect after a **full power cycle**, and is overwritten by the USB value upon a later reinstall.

There is **no cache, cache configuration, per-disc remembered table, or teaching mode**. The physical BD-J PSR20 handler remains active in both ISO settings. When virtual auto-region is disabled, virtual PSR20 calls are passed to the unmodified player handler rather than answered with a fabricated universal region.
