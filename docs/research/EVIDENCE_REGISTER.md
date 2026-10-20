# Engineering evidence register

This public evidence register describes **what was actually observed or tested** and points to curated technical documents. The underlying development archives and transient lab logs are maintained privately; public reports intentionally do not expose internal conversation numbering or obsolete experimental build labels.

| Technical claim | Evidence category | Documentation and qualification |
| --- | --- | --- |
| Runtime Blu-ray region can be changed without rewriting the saved setting | Hardware observation / interface study | [Architecture](ARCHITECTURE.md), [Development history](DEVELOPMENT_HISTORY.md) |
| A-only and B-only physical discs can be detected and played | Hardware playback | [Test evidence](TEST_EVIDENCE.md) |
| A+B physical HDMV and BD-J checks can select a permitted region | Hardware playback | [Test evidence](TEST_EVIDENCE.md) |
| B+C allows B or C and B was selected in tested cases | Physical / virtual playback | [Test evidence](TEST_EVIDENCE.md) |
| C-only and A+C decisions are represented by the detector | Synthetic Java and offline detection tests | [Region support](../REGION_SUPPORT.md); **no separate documented real-disc pass** |
| Unrestricted titles should not trigger a fabricated restriction | Region metadata / false-positive controls | [Region detection](REGION_DETECTION.md), [Test evidence](TEST_EVIDENCE.md) |
| Source change and virtual-region gate can be only ~20 ms apart | Instrumented development trace | [Virtual-media timing](VIRTUAL_MEDIA_TIMING.md) |
| Certain Java titles needed hundreds of milliseconds of region analysis | Measured detector execution | [Virtual-media timing](VIRTUAL_MEDIA_TIMING.md), not a universal load-time benchmark |
| Physical BD-J PSR20 and global region can temporarily differ | Hardware observation | [Physical BD-J](PHYSICAL_BDJ.md) |
| ISO/BDMV branch defaults on and can be disabled | Source and packaged config | [Configuration](../CONFIGURATION.md) |
| Runtime contains 44 immutable hashed files plus editable config | Nested installed-payload manifest | [Release engineering](RELEASE_ENGINEERING.md) |
| The maintainer confirms functional autoABC 1.0.0 | Maintainer confirmation | [Verification](../VERIFICATION.md), distinguished from repacked-ZIP offline tests |
| Exact README-free release files have not been modified functionally | Byte comparison of 50+ entries and manifest verification | [Release verification](../VERIFICATION.md) |

**Evidence boundaries:** hardware observations are title-specific; synthetic coverage is not hardware playback; file-integrity checks are not a live-installation test. Where exact internal timestamps, raw logs, or full native source are not public, this register identifies the resulting limitation rather than claiming independent third-party reproduction.
