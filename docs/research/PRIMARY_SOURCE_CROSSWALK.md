# Research topic index

This index connects the project's public technical reports to the questions that motivated them. It does not expose private source-file names, internal experiment IDs or conversation numbering.

| Research question | Relevant public report | Evidence |
| --- | --- | --- |
| Can a runtime region be selected independently of the saved region? | [Architecture](ARCHITECTURE.md) | Firmware interface observations |
| Which A/B/C region masks and check styles are recognized? | [Region detection](REGION_DETECTION.md), [Region support](../REGION_SUPPORT.md) | Semantic analysis and validation cases |
| Which physical discs and virtual titles were exercised? | [Test evidence](TEST_EVIDENCE.md) | Recorded title-specific tests |
| Why can a simple region string scan be misleading? | [Region detection](REGION_DETECTION.md) | False-positive and unreachable-check cases |
| Why do some ISO/BDMV titles require synchronous analysis? | [Virtual-media timing](VIRTUAL_MEDIA_TIMING.md) | Source lifecycle traces and detector timings |
| Why were late polling and broad suspension rejected? | [Failed approaches](FAILED_APPROACHES.md) | Repeated navigation and timing failures |
| How is physical BD-J PSR20 related to global region state? | [Physical BD-J](PHYSICAL_BDJ.md) | Hardware playback and session-state observations |
| How are installer integrity, runtime hashes and rollback checked? | [Release engineering](RELEASE_ENGINEERING.md) | Archive and source inspections |
| Which checks distinguish demonstrated behavior from incomplete evidence? | [Evidence register](EVIDENCE_REGISTER.md) | Explicit evidence classification |
