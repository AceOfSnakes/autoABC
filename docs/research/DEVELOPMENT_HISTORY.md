# Development history: autoABC 1.0.0

The following describes the engineering milestones, without internal chat numbering or superseded experimental release labels. Source categories and limits are documented in the [Evidence register](EVIDENCE_REGISTER.md).

## 1. Runtime region discovery

The initial finding was that a live Blu-ray region could be read and selected independently of the user's persisted setting. Direct HDMV checks, masks and branching behavior required more than pattern matching against raw strings. A conservative detector was developed to avoid making a region selection when the restriction was not demonstrated.

BD-J needed separate Java property and bytecode/callgraph analysis. Reaching a region-related method was insufficient to establish a lock: some titles use PSR20 for localization, and other checks are unreachable. Early disc trials established A-only, B-only and A+B playback, while additional cases supplied B+C and unrestricted-region evidence.

## 2. Virtual-media preplay synchronization

ISO and BDMV source changes can precede their region-sensitive setup calls by only a short interval. Asynchronous polling could identify the right region but still miss the decision point, especially when Java analysis took hundreds of milliseconds. Temporarily stopping the entire player process also introduced menu and file-descriptor reliability problems.

The adopted path synchronizes a checked callsite before the player evaluates the virtual region. It validates the source before and after analysis, performs a fast pass followed by HDMV or Java fallback when needed, and uses session-aware restoration. The optional virtual-media branch is documented in [Virtual-media timing](VIRTUAL_MEDIA_TIMING.md).

## 3. BD-J PSR20 state and session handling

The global CBR status and BD-J PSR20 mailbox can represent different pieces of runtime state. A title could play successfully with a suitable PSR20 response while the global status already showed STOCK. Distinguishing physical from virtual media prevented unrelated source transitions from overwriting the wrong context.

Physical BD-J session management was refined with a cautious playback-state heuristic, avoiding premature restoration in demonstrated *Avatar* playback, STOP/HOME and replay tests. The heuristics are not an official universal decoder-state API and remain title-dependent.

## 4. Package hardening and configuration

The final installation uses a guarded jailbreak-overlay boot integration, exact code-signature checks, manifest-pinned runtime content, separate install/uninstall launchers and explicit result logs. A persistent disc cache was removed; the only user option is `ISO_BDMV=1` (default) or `ISO_BDMV=0` for physical-disc-only auto-region.

The release contains 44 immutable installed files and one editable config. The maintainer confirmed the 1.0.0 mod works. The published installer/uninstaller archives retain identical functional member bytes and their final hashes were verified offline.

## Design principles

- Keep the saved region unchanged; select the region at runtime when justified.
- Handle HDMV, BD-J, physical media, ISO and BDMV as distinct authoring/lifecycle categories.
- Treat unrestricted and ambiguous region checks conservatively.
- Verify process identity, source identity, code signatures and boot-wrapper ownership before writing RAM or boot files.
- Restore region state after playback and preserve the existing jailbreak overlay on removal.
- Publish real tests and important negative results without mistaking synthetic tests for hardware passes.

Further reading: [Architecture](ARCHITECTURE.md), [Failed approaches](FAILED_APPROACHES.md), [Test evidence](TEST_EVIDENCE.md).
