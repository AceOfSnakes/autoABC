# Primary source crosswalk by topic and source section

This table makes the public research narrative traceable to the four private original documentation files. The D1-D4 labels and their exact SHA-256 identities are listed in [the evidence register](EVIDENCE_REGISTER.md). Chat numbering is derived from the *source filename*, never the heading inside the file.

| Topic in this repository | Original source chapters to consult | Type of evidence |
| --- | --- | --- |
| Runtime global region and persisted STOCK independence | [D1] Sections 3, 4, 6, 9 and 11 | Architecture + early original-player observation |
| Physical HDMV detection and masks | [D1] Sections 15-19, 21-24, 26 and 28 | Static decoder analysis + selected hardware checks |
| False positives and benign PSR20 references | [D1] Sections 16-18 and 29; [D2] Section 3 | Negative corpus + detector rationale |
| BD-J Java config and callgraph detection | [D1] Sections 21-26; [D2] Sections 4, 14, 22, 33 | Native/callgraph analyses + selected hardware checks |
| ISO and BDMV virtual mount/lifecycle | [D1] Sections 8-10; [D2] Sections 11-17, 24-30 | Source-lifecycle and hook experiments |
| Why asynchronous watchers were too late | [D2] Section 26 | Timing trace: ~20 ms source transition vs analysis times |
| Example virtual BD-J detector costs | [D2] Section 46 | Historical measurement: ~338+595 ms ISO, ~510+710 ms BDMV |
| Why process suspension and late hooks failed | [D2] Sections 12-18, 22, 27 and 45 | Failed live tests + diagnostic traces |
| Working synchronous preplay pathway | [D2] Sections 29-32 and 34 | Design, code path, live virtual-media results |
| PSR20 mailbox vs global CBR | [D3] Sections 6-8; [D4] Sections 2-4 | Hardware observations and state correlation |
| Physical BD-J STOP/HOME replay heuristic | [D4] Sections 4 and 5 | Original-player HBI and replay hardware traces |
| ISO_BDMV on/off and PASS-through guard | [D4] Sections 6, 7 and 15 | Config behavior on hardware predecessor; current source logic |
| Cache removal | [D4] Sections 6.3, 7 and 16 | Product decision, not hardware speed certification |
| Release payload cleanup and manifests | [D4] Sections 8, 9, 12, 13 and 20 | File-by-file offline audit and current sealed archives |
| MTK uninstall launcher failed then was repaired | [D4] Sections 11-14 and 22 | First failure observed on hardware; corrected build only offline verified |
| Outstanding rights and hardware acceptance | [D4] Sections 21, 22 and 25 | Documented open gates, not completed tests |

The source crosswalk is provided to facilitate independent review **by the maintainer with access to the private evidence**. It is not a substitute for publicly redistributable source files where those are legally available.
