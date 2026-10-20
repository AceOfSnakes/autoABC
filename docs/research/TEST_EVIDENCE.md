# Media test evidence and known unknowns

This is a **curated historic regression corpus**, not a claim that every title was rerun with the two exact sealed 1.0.0 ZIPs. Disc editions differ; an observed result on one pressing does not automatically apply to another release. Refer to [Sources D1-D4](../SOURCES.md).

| Test title / case | Examined behavior | Evidence characterization |
| --- | --- | --- |
| *Me and You and Everyone We Know* | BD-J title requiring A under a different stock setting | Prior physical-disc hardware pass [D1] |
| *LOST* season-four disc | HDMV B restriction with incorrect stock region | Prior physical-disc hardware pass [D1] |
| *LOVECUT* | Sequential HDMV B check; runtime selected B | Prior physical-disc hardware pass [D1], later regression [D2] |
| *Aftersun* | HDMV B selection from an allowed B/C region case | Prior physical-disc hardware pass [D1], later regression [D2] |
| *Cinema Paradiso* | Multi-region A+B allowed, C disallowed; selected A from stock C | Prior physical-disc hardware pass [D1]; navigation regressions were tracked in virtual-gate experiments [D2] |
| *Prometheus* special-features disc | BD-J A+B allowed, C disallowed; selected A after C was forced | Prior physical-disc hardware pass [D1] |
| *Breaking Bad*, season-four disc | A+B mask; selected A and played | Prior hardware observation [D2] |
| *Avatar* Collector's Edition BD-J physical disc | B-region PSR20 handling; physical playback hold, STOP/HOME and replay | Prior original UDP-203 hardware pass for the playback-state change [D4] |
| *Avatar* ISO | Ambiguous B/C Java callgraph; chose B; stock restored when session finished | Prior hardware/virtual-path observation [D2], [D3] |
| *Avatar* BDMV folder | Correct B selection required synchronous preplay; experimental suspension could freeze navigation | Prior hardware observation of final interception approach [D2] |
| *The Straight Story* | Physical HDMV selection and replay behavior | Prior hardware report [D3], [D4] |
| *Patlabor*, *Unstoppable* and other titles | Different disc structures and successful developer regressions | Historical coverage noted [D3]; not a 1.0.0 universal guarantee |

## Important negative controls

The research intentionally distinguished titles with no confirmed lock from titles requiring an override. Examples included another *LOST* season disc with benign PSR20 uses, *Twin Peaks* BD-J code that looked region-aware but did not prove an active lock, and Java classes with unreachable tests. Other titles were intentionally recorded as UNKNOWN rather than force an answer. [D1], [D2].

## What still needs final end-to-end acceptance

The **latest final install/uninstall ZIP pair**, not merely the underlying algorithm, must be tested on the actual target: installation, both ISO configuration states, physical HDMV and BD-J regression, STOP/HOME/EJECT, status read-only checker, removal, restoration of the pre-existing boot monitor and reinstall. See [Verification](../VERIFICATION.md).

## Testing boundaries

- No test here is evidence that autoABC removes UHD/AACS/Cinavia restrictions or DVD region checks.
- `ISO_BDMV=0` means no automatic region selection for virtual media, not a guarantee that a region-locked virtual image will start.
- Disc region masks and Java code may vary between releases, localizations and revised pressings.
- Do not upload copyrighted disc images or proprietary decrypted media in GitHub issues.
