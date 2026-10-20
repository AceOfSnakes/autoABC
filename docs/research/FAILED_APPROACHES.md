# Investigations and rejected approaches

Negative results helped shape a safer 1.0.0 design. These are historical engineering findings, not instructions to reproduce unsafe tests on a production device.

| Investigated approach | Observation | Resulting design decision |
| --- | --- | --- |
| Poll virtual BDMV filesystem links | Source transition to region gate could take ~20 ms, whereas complex detection took hundreds of milliseconds | Use a checked synchronous preplay interception |
| Freeze the entire player process while inspecting a virtual BDMV source | Could disturb disc menus and active file-descriptor state | Avoid broad `SIGSTOP` during navigation |
| Reuse a virtual-media hold for physical-disc startup | Different initialization and session ownership caused inconsistencies | Keep physical and virtual pipelines distinct |
| Reliance on source/FD timing-only state machines | Insert/eject, replay and cancellation created stale/ambiguous states | Verify current source at the actual setup call |
| Hook a convenient-looking helper rather than an observed callsite | Some hooks never intercepted the required BDMV operation | Validate exact callsites and binary signatures |
| Infer global region from BD-J PSR20 alone | PSR20 could return B while global CBR showed STOCK | Track mailbox and global state separately |
| Treat one playback-state value as universal PLAY/STOP | BD-J menus can look like background playback | Combine multiple samples with conservative fallbacks |
| Disable virtual handling merely by stopping daemons | Residual PSR20 interactions could persist | Use an explicit native-handler pass-through guard when ISO/BDMV is off |
| Retain a permanent cache for speed | Marginal proven benefit, additional stale fingerprint risk | No cache in 1.0.0 |
| Refactor active paths wholesale for naming cleanup | Stable hooks could become unreachable or be nested incorrectly | Preserve byte-validated runtime interfaces |
| Replace boot wrappers without ownership checks | Could destroy unrelated modifications or break early startup | Fail closed on unknown owners and validate backups |
| Rely on arbitrary MTK uninstall launcher formatting | One earlier uninstall launch appeared inactive | Use a short launcher with verified CRLF and correct layout |
| Copy macOS metadata to USB | AppleDouble and `.DS_Store` files are irrelevant payload | Package fixed, manifest-pinned file sets only |
| Require an exact hash of any pre-existing `brick_monitor` | Different valid overlay states have different hashes | Validate ownership and structure rather than a single universal hash |

For the final architecture see [Architecture](ARCHITECTURE.md); for specific timing observations see [Virtual-media timing](VIRTUAL_MEDIA_TIMING.md); for the boundaries of live/synthetic validation see [Evidence register](EVIDENCE_REGISTER.md).
