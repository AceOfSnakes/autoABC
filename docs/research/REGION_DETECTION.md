# Blu-ray region detection, allowed masks and false positives

The key discovery was that *finding a reference to a region register is not the same as proving a region lock*. Blu-ray titles may read PSR20 to choose languages, warnings, menus or other behavior even when all regions play. autoABC therefore distinguishes a verified A/B/C decision from UNKNOWN rather than forcing a region on every Java or HDMV program. [D1]-[D3].

## Region labels and masks

Blu-ray region masks use three allowed-region bits in the tested detection pathways:

| Bit | Region |
| --- | --- |
| 1 | A |
| 2 | B |
| 4 | C |

Examples: `3 = A+B`, `5 = A+C`, `6 = B+C`, `7 = A+B+C`. A mask is not a one-hot region and does not mean that the selected runtime should be set to its numeric value. A compatible region is selected when necessary. If no meaningful restriction is detected, the mod should preserve or restore normal stock behavior rather than claim that everything was bypassed.

## HDMV / MovieObject analysis

`MovieObject.bdmv` and associated control flow can express a region check as direct comparisons, masked checks, sequential branches, exclusion conditions or indirect paths. Simple byte-string detection can produce both false negatives and false positives. The engineering work introduced a native semantic analyzer and HDMV validator/fallback. `preplay_virtual.sh` first uses the fast detector; a conflicting concrete HDMV answer can override a concrete core answer. When unresolved, the BD-J path can be consulted as appropriate. [D1], [D2].

## BD-J analysis

The native BD-J analyzer examines properties and JAR bytecode/callgraphs for reachable region logic, including comparisons with PSR20. A region string that exists in an unreachable class is not adequate evidence; the testing corpus deliberately included misleading Java checks and benign PSR20 usage. BD-J applications can be region restricted in more than one region and can defer the check until after disc navigation begins.

A separate PSR20 runtime mailbox allows the checked firmware getter to return a compatible A/B/C value on demand. The global status register can independently display STOCK. This is not the same as changing the persistent player setting. See [Physical BD-J](PHYSICAL_BDJ.md).

## Conservative rules

1. Keep A/B/C mask semantics explicit and separate them from the raw byte encoding of runtime CBR.
2. Avoid changing regions when the detector finds no justified restriction.
3. Avoid treating a missing/rejected parser result as "region free".
4. Recheck source identity and process ownership before applying a result.
5. Keep physical disc and virtual media handling separate.
6. Treat unsupported Java control flows as limitations, not as evidence that the restriction has been removed.

## Negative controls used in research

Some discs include region-check-looking Java bytecode but do not enforce a region lock, some use PSR20 for localization, and others keep disabled checks as leftovers. Specific regression controls included a season-disc comparison from *LOST*, a *Twin Peaks* Java title and several other UNKNOWN cases. [D1] The aim was to minimize accidental region changes, not to maximize the number of strings matched.

References: [D1] "Disc-lock families", "False-positive/no-lock families", "Native Java core"; [D2] "Detector architecture"; [D3] "Core/HDMV/BD-J".
