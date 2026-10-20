# Experiments, ruled-out approaches and negative results

A release research folder is useful only if it also records **why reasonable-looking alternatives were abandoned**. The items below summarize documented experiments, with evidence classes and limits. They are not recommendations to reproduce crashes on production hardware. Source anchors in [Evidence register](EVIDENCE_REGISTER.md).

| Investigated approach | Observed problem / counterexample | Engineering conclusion | Sources |
| --- | --- | --- | --- |
| Poll filesystem links to detect new BDMV before the region gate | Link->virtual state observed in ~20 ms; detector work hundreds of ms | Asynchronous observers are too late for complex titles; require synchronous preplay coordination | [D2] |
| Stop the whole player process while a virtual BDMV source appears | Helped selected region-locked content, but could freeze menu navigation/UI or collide with file descriptors | Avoid broad `SIGSTOP` during UI/navigation; hold a narrower call site | [D2] |
| Stop physical playback at the same point as virtual media | Physical-disc process suspension was unreliable; startup/mount sequence differed | Keep physical and virtual media paths separate | [D2], [D3] |
| Source/FD replay tracking with elaborate shell state machines | Reinsert/replay, cancellation timing and stale descriptors introduced complexity | Prefer native lifecycle and verified source state over inferred timers | [D2] |
| React solely to `/mnt/link` to decide a BDMV region | Link change did not guarantee the current player call was blocked until detection finished | Recheck source identity inside the synchronous hook | [D2] |
| Hook a convenient-looking generic helper rather than the true BDMV callsite | Hook appeared installed but no useful preplay invocation; delayed or wrong-site interception | Measure real callsites and exact byte signatures, not names alone | [D2] |
| Infer global CBR from BD-J PSR20 mailbox status | Physical BD-J could play with mailbox=B while global CBR=STOCK | Treat mailbox and global region as independent state | [D3], [D4] |
| Treat a generic HBI selector as a universal STOP signal | Menu/background playback could look like active playback after HOME | Use conservative multiple samples, thread evidence, and explicitly report untested disc classes | [D4] |
| Enable a virtual hook only by starting/stopping its daemon | Residual cross-source behavior possible for PSR20 in ISO-off mode | Use an explicit original-handler PASS-through guard when ISO/BDMV auto-region is disabled | [D4] |
| Include region cache for convenience | Limited demonstrated payoff and more fingerprint/stale-state risk | No cache in the public 1.0.0 design | [D4] |
| Aggressively replace filenames/status paths during release refactoring | Working feature paths could silently become unreachable | Refactor only with binary and runtime equivalence checks | [D3], [D4] |
| Import historic hook layouts for compatibility | Unknown code cave ownership and patch signature could become unsafe | Fail closed on unknown/foreign hook sites; no blind migration | [D4] |
| Trust any USB `AutoScript.TSS` text formatting for uninstall | Earlier standalone uninstall appeared to do nothing on hardware; CRLF and command lengths were suspected | Use short MTK-compatible CRLF launcher; still require live retest | [D4] |
| Unconditionally copy every file extracted by macOS | `._*` AppleDouble and `.DS_Store` artifacts could leak into installed runtime | Copy only fixed manifest-pinned runtime files; keep editable config separate | [D4] |
| Require a single fixed hash for existing `brick_monitor` | Legitimate prior overlay builds vary | Validate actual owner/structure, backup integrity and symlinks rather than blindly whitelisting one hash | [D4] |

## Negative-test discipline

When a new hypothesis fails, record (a) the exact state and media path, (b) what was measured or logged, (c) what must not be repeated, and (d) the safer fallback. The current public repository does not include legacy binaries or executable test instructions that can reintroduce known bad RAM patches. A successful offline check of syntax or ZIP archives **never substitutes** for a successful live device-state transition.

See also [Development history](DEVELOPMENT_HISTORY.md), [Virtual-media timing](VIRTUAL_MEDIA_TIMING.md) and [Physical BD-J](PHYSICAL_BDJ.md).
