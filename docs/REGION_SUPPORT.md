# Blu-ray region support and validation

[Back to the main README](../README.md) · [Media test evidence](research/TEST_EVIDENCE.md)

## What autoABC supports

autoABC implements automatic selection among the three standard Blu-ray region identities, **A**, **B** and **C**, and handles **all seven nonempty allowed-region combinations**. Multi-region masks express what a title *permits*; they are not the same as the value the player should report as its selected region.

| Allowed-region mask | Region type | Selection logic | Evidence level |
| --- | --- | --- | --- |
| `1` | A only | A | Physical BD-J playback tested |
| `2` | B only | B | Physical HDMV playback tested |
| `4` | C only | C | Synthetic detection test; no separately recorded C-only physical disc |
| `3` | A+B | Compatible allowed region (commonly A) | Physical HDMV and BD-J playback tested |
| `5` | A+C | Compatible allowed region | Synthetic detection test; no separately recorded A+C physical disc |
| `6` | B+C | Compatible allowed region (commonly B) | Physical restriction / ISO and BDMV playback tested |
| `7` | A+B+C / unrestricted | Keep ordinary behavior when no lock is established | Unrestricted-title metadata and false-positive controls |

Blu-ray region-free packaging can be shown as **ABC**, **region free** or sometimes without an explicit logo. Sony's region guide gives the three lettered regions and the region-free classification. [External references](SOURCES.md).

## Region-check approaches included in the implementation

- **HDMV / MovieObject:** direct comparisons, sequential checks, masks, exclusion patterns and indirect control-flow cases recognized by the semantic detector.
- **BD-J:** region property sets and reachable Java bytecode/callgraph checks, including PSR20 reads.
- **Multi-region:** A+B, A+C and B+C allowed-region sets, with a deterministic compatible-region choice.
- **Unrestricted and ambiguous cases:** avoid false region forcing when evidence is insufficient; preserve normal region behavior where appropriate.
- **Media paths:** physical discs, and optionally Blu-ray ISO images and BDMV folders; these have different detection timing and session lifecycles.

## Compatibility statement

**All seven standard A/B/C region combinations are represented by the implemented detection and selection logic.** Extensive disc and synthetic testing targeted different region restrictions and authoring approaches. This is support for the *region types*, not an assurance that every disc worldwide is compatible: editions can contain publisher-specific BD-J code, unexpected branches, malformed metadata, country-related conditions or other checks outside autoABC's scope.

In particular, **C-only and A+C are algorithmically and synthetically covered but have no separately documented live physical-disc pass** in the available test record. A+B, B-only and A-only have live disc evidence; B+C has live disc and virtual-media evidence. This distinction should be preserved in later release claims.

autoABC changes neither DVD regions nor BD-J's separate country register (PSR19). Region selection alone cannot remedy media, DRM, encryption, menu or unrelated firmware compatibility issues.
