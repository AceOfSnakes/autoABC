# Development history: how autoABC reached 1.0.0

This history follows the chronology documented in the four source conversations, while using technical milestones rather than old internal test package names. It makes no assertion that every intermediate experiment was safe or publicly releasable. Primary evidence: [D1]-[D4] in [Sources](../SOURCES.md).

## Stage 1 - Finding the live Blu-ray region interface [D1]

The first central discovery was that the player's runtime Blu-ray region can be observed and selected independently of its persisted configuration. A command-line controller was built to read and change the running player process's region state. Early probes distinguished ordinary global region state (CBR) from other player registers; the persistent stock setting was intentionally left unchanged.

A physical-disc watcher was explored as a way to react to a newly inserted disc. Parsing `MovieObject.bdmv` gave an initial path into HDMV region checks, but crude detection rules could miss indirect/bitmask logic and could misclassify discs whose PSR20 references were merely for localization. The detector was revised to interpret native HDMV control flow and only apply an A/B/C answer backed by a plausible restriction. Fail-safe UNKNOWN remained important.

BD-J discs required examining JAR bytecode and application configuration, including literal region sets, comparisons to PSR20 and call paths reachable from the relevant Java entry points. A multi-region mask such as A+B is not the same as a single locked region; when the player's stock region is allowed it need not be needlessly changed.

The early hardware corpus included A-only, B-only, A+B and B+C examples, together with `UNKNOWN` controls to check false positives. This established that automatic selection was possible but that the timing of the decision was as important as the decision itself.

## Stage 2 - Solving virtual-media timing without freezing the UI [D2]

ISO and BDMV folder playback use internal source/loop-mount lifecycles that differ from physical disc insertion. An asynchronous filesystem watcher could observe a new media source, but for complex BD-J titles the player reached its region gate in around 20 ms, whereas semantic detection took hundreds of milliseconds. This explains why a detector that produced the correct answer when run manually could still be too late for automatic playback.

Several generations of `SIGSTOP` and source-latching strategies were tried. They could force a decision early enough but sometimes suspended a process inside the player's own folder navigation or file-descriptor lifecycle, causing UI freezes or unreliable replay. The experiment logs led to abandoning broad process suspension and selecting a narrow synchronous interception at verified player call sites.

A guarded preplay hook now runs the fast detector first, then HDMV validation/fallback and the BD-J callgraph when needed. It rechecks that the mounted source has not changed before committing a region. Independent virtual-state monitoring holds the decision for the relevant session and restores STOCK when playback ends. A complex Java title consequently may show a roughly one-second analysis pause; this is the documented price of correct preplay timing, not a hang.

## Stage 3 - Stabilizing physical BD-J and cross-source state [D3]

Physical HDMV and BD-J paths were separated from ISO/BDMV behavior. PSR20 uses a mailbox/intercept mechanism that can supply the BD-J application a compatible runtime region while the separately visible global CBR remains STOCK. That means a stock-looking status output during a successfully playing BD-J disc is not, by itself, a detector failure.

Cross-routing was important: virtual player transitions and physical disc state must not be confused, and a global region write can be reverted independently of the PSR20 response. Early-boot startup moved under a guarded existing jailbreak-overlay launcher rather than modifying the firmware image. Player and hook signatures, process validation, rollback and status tooling were emphasized over aggressive optimization. Several older configuration refactors were set aside because they accidentally changed already working paths.

## Stage 4 - Playback-aware restoration and final packaging [D4]

Hardware traces established that one physical BD-J title could continue requesting region B through the PSR20 hook while the global CBR was restored prematurely. An additional playback-state signal from the player decoder/HBI state was therefore used *only* in the physical BD-J fallback, not for ordinary HDMV or virtual playback. Consecutive state samples and thread-count changes help avoid writing a new region for every transient UI state. The behavior was checked on real hardware, including PLAY, STOP/HOME and replay on the target title.

An ISO/BDMV on/off option was separated cleanly from physical disc selection. A PASS-through guard preserves native virtual PSR20 behavior when the option is off. A cache was investigated but then removed: its demonstrated benefit was limited, while false/stale entries and extra state introduced additional risk. The finished configuration has just `ISO_BDMV` and defaults to `1`.

The packaging phase reduced installed runtime objects to 45 (44 hashed immutable files plus one editable config), removed unused hook fragments, consolidated status displays and fixed Mac metadata leakage. Install and uninstall were split into independent AutoScript archives; both gained stronger checks and explicit result logs. A faulty initial uninstall AutoScript launcher that appeared not to run on the real player motivated a short CRLF MTK command sequence and separate repair testing. The final ZIPs were then checked extensively offline, but **their final complete USB install/uninstall flows still await an independently documented live-device pass**.

## Architectural principles retained

- Never change the persisted factory region simply to make a title play.
- Prefer a confirmed region over speculative region-free behavior.
- Observe physical and virtual playback lifecycles separately.
- Validate the current process, source, code signature and hook owner before writing memory.
- Refuse unknown bootstrap layouts rather than chaining arbitrary wrappers.
- Restore or roll back the previous state when verification fails.
- Preserve byte-for-byte release inputs for auditability; do not relabel intermediate tests as public releases.

Further technical detail: [Architecture](ARCHITECTURE.md), [Failed approaches](FAILED_APPROACHES.md), [Release engineering](RELEASE_ENGINEERING.md).
