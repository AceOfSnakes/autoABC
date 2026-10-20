# Blu-ray region masks and detector design

The key engineering lesson is that **finding a reference to a region register does not prove a disc has an active region lock**. A disc can read PSR20 for localization, warnings or other behavior without forbidding playback in a given region. autoABC distinguishes a concrete A/B/C restriction from an ambiguous or absent check.

## Masks and player values

Blu-ray allowed-region sets are represented internally as three bits: **1=A, 2=B, 4=C**. The combinations are A(1), B(2), C(4), A+B(3), A+C(5), B+C(6), A+B+C(7). The selected player region uses A, B or C; **an allowed-region mask is not the selected region itself**. See the complete [support matrix](../REGION_SUPPORT.md).

The Blu-ray player's PSR20 region register is commonly documented as 1 (A), 2 (B), 4 (C). The separate global runtime CBR state uses its own representation and must not be conflated with mask bits. [Technical references](../SOURCES.md).

## Physical HDMV / MovieObject checks

`MovieObject.bdmv` may express a restriction through direct region comparisons, branching conditions, exclusion patterns, masks or sequential fallback branches. A byte-string scan can miss the actual logic or misinterpret a harmless literal; the parser therefore examines the control-flow meaning and validates uncertain results conservatively. A title allowed in A+B can select A rather than being incorrectly classified as the numeric region "3".

## BD-J and PSR20 checks

The BD-J path analyzes JAR configuration and reachable Java bytecode / callgraphs. A name or method reference to a region check can exist without an active lock, especially in unused branches or generic frameworks. For applicable physical BD-J cases the PSR20 handler can supply the selected A/B/C identity while playback continues. Physical and virtual media use different lifecycle synchronization; see [Physical BD-J](PHYSICAL_BDJ.md) and [Virtual-media timing](VIRTUAL_MEDIA_TIMING.md).

## False-positive controls and fallback

Negative controls included region-aware-looking Java that ultimately allowed A+B+C, disc code that read PSR20 only for nonblocking behavior, unreachable checker branches and ambiguous cases classified as UNKNOWN. These prevent an automatic region change from being triggered by any incidental PSR20 reference.

**Synthetic tests include C-only and A+C detection; no distinct physical disc pass was documented for those combinations.** Hardware evidence covers A-only, B-only, A+B and B+C. [Test evidence](TEST_EVIDENCE.md) and [Evidence register](EVIDENCE_REGISTER.md).
