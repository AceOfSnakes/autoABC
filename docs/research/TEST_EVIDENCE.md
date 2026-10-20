# Disc, authoring and region-type test evidence

This is a curated record of project testing, including physical-disc runs, virtual-media playback, syntax-level checks and synthetic region-mask tests. Disc editions can differ. Hardware observations describe individual tested titles, not a promise that any other pressing uses identical region code.

| Example / test family | Region type | Authoring / check type | Observed outcome and evidence |
| --- | --- | --- | --- |
| *Me and You and Everyone We Know* | **A only** | Physical BD-J | Selected A despite a different saved region; playback verified on the UDP-203 |
| *LOST* season 4 disc | **B only** | Physical HDMV | B restriction recognized; playback verified |
| *LOVECUT* | **B only** | Sequential HDMV | B selected from another stock region; playback verified |
| *Aftersun* | **B+C** (allowed-mask pattern) | Physical HDMV / bitmask check | B selected from stock A; playback verified |
| *Cinema Paradiso* | **A+B** | Physical HDMV | A selected when C was the saved region; playback verified |
| *Prometheus* special features | **A+B** | Physical BD-J property set / PSR20 | A selected after a C setting; playback verified |
| *Breaking Bad* season 4 disc | **A+B** | Region-mask case | Selected A and played on hardware |
| *Avatar* Collector's Edition disc | **B** runtime choice / BD-J | Physical PSR20 | Playback, STOP/HOME, return-to-stock and replay tested |
| *Avatar* ISO | **B+C** mask, selected B | BD-J Java callgraph | Region B selected; playback and restoration observed |
| *Avatar* BDMV folder | **B+C** mask, selected B | Synchronous virtual-media preplay | Correct selection and playback observed; earlier generic process-stop experiments could freeze navigation |
| *The Straight Story* | **B** | Physical HDMV | Region selection and replay exercised |
| *Patlabor*, *Unstoppable* and other titles | Mixed | Additional regression media | Playback and region-control scenarios tested; not blanket compatibility certification |
| Synthetic Java checks | **A**, **B**, **C**, **A+C** | Controlled detector inputs | Expected decisions recognized; does **not** stand in for a C-only or A+C physical-disc pass |
| *Black Swan* and *Prometheus* bonus-disc test content | **A+B+C / unrestricted** | Region properties without active restriction | Used to verify the detector does not invent a lock merely because region code exists |
| Another *LOST* season disc, *Twin Peaks* and benign PSR20 cases | **UNKNOWN / no proven lock** | False-positive controls | Detector avoided asserting a definite region when the check was absent, unreachable or inconclusive |

## Evidence qualification

- **Physical hardware evidence:** the specified title or disc was tested on an OPPO UDP-203 in the development record.
- **Virtual playback evidence:** ISO or BDMV region detection was exercised in playback; this is not automatically the same as a physical retail-disc pass.
- **Synthetic / static evidence:** an explicitly constructed detection case or parsed source pattern checked algorithm coverage without proving playback of a real disc.
- **Final version:** autoABC 1.0.0 is reported working by the maintainer. The published USB archives contain byte-identical functional payload files and passed offline archive verification.

The **C-only** and **A+C** region combinations are implemented but lack separately documented physical-disc confirmations in the supplied research. Different releases may use unusual Java, additional country conditions or unrelated player checks. No universal per-title playback guarantee is made.

For the full seven-combination support table see [Region support](../REGION_SUPPORT.md); for why some region-like code must be treated as UNKNOWN see [Region detection](REGION_DETECTION.md).
