# autoABC technical research

This folder documents the work behind the automatic Blu-ray region selector: firmware integration, HDMV and BD-J analysis, PSR20 handling, ISO/BDMV timing, negative controls and installer safety. It is an engineering reference, **not a log of public version numbers**.

## Start here

- [Architecture](ARCHITECTURE.md) — process hooks, detector layers and region state.
- [Development history](DEVELOPMENT_HISTORY.md) — the design decisions that led to autoABC 1.0.0.
- [Region detection](REGION_DETECTION.md) — HDMV/BD-J semantics, masks and false positives.
- [Physical BD-J](PHYSICAL_BDJ.md) — PSR20 and playback-state restoration.
- [Virtual-media timing](VIRTUAL_MEDIA_TIMING.md) — ISO and BDMV interception, timing data and configuration tradeoffs.
- [Failed approaches](FAILED_APPROACHES.md) — important rejected designs and why.
- [Test evidence](TEST_EVIDENCE.md) — playback examples, synthetic coverage and caveats.
- [Evidence register](EVIDENCE_REGISTER.md) — claim-to-observation mapping.
- [Research topic index](PRIMARY_SOURCE_CROSSWALK.md) — quick reference by engineering problem.
- [Release engineering](RELEASE_ENGINEERING.md) — archive manifests, source parity and safety gates.

## How to read the evidence

- **Hardware observed:** result reported from playback or controls on an OPPO UDP-203.
- **Synthetic / offline:** verified against constructed input, firmware inspection or an archive test, not necessarily real disc playback.
- **Inferred:** design explanation consistent with recorded results, but not a universal assertion.
- **Open:** no sufficient test to justify a broad claim.

Technical observations are project research, not independent certification by the Blu-ray Disc Association, Sony or OPPO Digital. External standards and player references are listed in [Sources](../SOURCES.md).
