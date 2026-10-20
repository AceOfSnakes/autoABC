# Compatibility and limitations

| Requirement | Status |
| --- | --- |
| **OPPO UDP-203 with RU-JB 65-0131 jailbreak firmware** | Required environment |
| Four matching live firmware-code signatures | Required; installer refuses an unexpected signature |
| Working jailbreak overlay and early-boot launcher | Required |
| Compatible live `bdpprog.1` process | Required for installation validation |
| USB AutoScript support | Required for the packaged installer and uninstaller |
| Physical HDMV / BD-J Blu-ray | Included |
| ISO / BDMV region detection | Optional; default enabled |
| DVD region switching | Not provided |

**A matching firmware version display alone is not a guarantee of compatibility.** The installer performs exact code-signature checks, verifies the runtime payload and inspects the current boot-wrapper ownership. It refuses mismatches or ambiguous ownership rather than guessing.

This is not a firmware update. It changes runtime player-memory state and integrates with the jailbreak overlay's early-boot startup. A recovery plan is recommended before installation.

## Playback limitations

- Region support covers all standard A/B/C allowed-region combinations, but **not all individual discs or custom navigation programs are guaranteed**. See [Region support](REGION_SUPPORT.md).
- BD-J can use PSR20 for more than region enforcement; a mere Java reference is not evidence of a lock. Ambiguous results may be treated as UNKNOWN.
- During BD-J playback, a global status view may differ from the region supplied by the PSR20 handler. Session state and restoration should be evaluated separately.
- Certain virtual BD-J titles may open more slowly when `ISO_BDMV=1`. Disable only the virtual-media region handler with `ISO_BDMV=0` if this matters more than automatic virtual region selection.
- The project does not bypass AACS, Cinavia, UHD copy protection, or DVD region coding.

[Evidence and test examples](research/TEST_EVIDENCE.md) · [Verification](VERIFICATION.md)
