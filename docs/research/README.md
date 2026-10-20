# autoABC research and development documentation

This folder is an English, curated technical narrative of the four successive development conversations. It is not a copy of every intermediate experiment. The aims are to preserve what was learned, show why the final design took this shape, document dead ends so others do not repeat them, and separate hardware observations from inference.

## Reading order

1. [Development history](DEVELOPMENT_HISTORY.md) - progression from runtime region control to the hardened release.
2. [System architecture](ARCHITECTURE.md) - detection engines, runtime hooks and lifecycle.
3. [Region detection](REGION_DETECTION.md) - HDMV, BD-J, masks and false positives.
4. [Virtual media and timing](VIRTUAL_MEDIA_TIMING.md) - why ISO/BDMV needs preplay coordination and when loading is longer.
5. [Physical BD-J and playback state](PHYSICAL_BDJ.md) - PSR20 mailbox vs global runtime region, conservative STOP/HOME logic.
6. [Experiments and failed approaches](FAILED_APPROACHES.md) - negative evidence and engineering lessons.
7. [Title test evidence](TEST_EVIDENCE.md) - observed examples and limitations.
8. [Release engineering](RELEASE_ENGINEERING.md) - early-boot wrapper safety, package integrity and offline vs hardware status.
9. [Evidence register](EVIDENCE_REGISTER.md) - SHA-pinned four primary documents, original references and claim provenance.
10. [Primary source crosswalk](PRIMARY_SOURCE_CROSSWALK.md) - direct chapter references to the four original source documents.

All history is organized by **topic and technical milestone**, not by superseded internal archive numbers. The public release name is always **autoABC 1.0.0**.

### Evidence categories

- **Hardware observed:** result reported from playback or controls on an original OPPO UDP-203.
- **Offline validated:** test fixtures, archive checks, mock shell runs or static analysis.
- **Engineering inference:** explanation best supported by logs/architecture but not separately proven by a dedicated hardware test.
- **Open limitation:** unresolved or not tested with the sealed final ZIP pair.

Internal sources are labeled [D1] to [D4] in [Sources](../SOURCES.md); the historic source files are retained privately rather than republished verbatim because they include superseded scripts, model-specific dumps and incomplete claims.
