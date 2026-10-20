# autoABC architecture

## Device/runtime layers

`autoABC` is an additional runtime service on the supported OPPO UDP-203 jailbreak environment. It **does not rewrite the OPPO firmware image** or drive firmware. It installs owned scripts and detector executables under `/mnt/ubi_boot/autoABC`, uses a guarded early-boot wrapper around the existing jailbreak overlay `brick_monitor`, and uses checked, process-local RAM patches on the running `bdpprog.1` player.

Three layers work together:

1. **Selection:** classify the current media source and infer an allowed Blu-ray region (or UNKNOWN) from HDMV or BD-J logic.
2. **Timing:** intercept or gate the relevant point in playback startup so that the chosen region is applied before the player/disc evaluates the restriction.
3. **Lifecycle:** keep the selected region in the correct scope, avoid confused physical-versus-virtual state, restore stock behavior on STOP/HOME/EJECT or session end as observed.

## Important runtime components

| Runtime component | Purpose | Format in sealed installer |
| --- | --- | --- |
| `autoabc_detect` | Native fast region detection from Blu-ray structures | ARM ELF |
| `autoabc_hdmv` | HDMV semantic fallback / validator | ARM ELF |
| `autoabc_bdj` | BD-J bytecode/callgraph examination | ARM ELF |
| `autoabc_folder` | Virtual folder state helper | ARM ELF |
| `autoabc_disc` | Physical disc observation, selection and session lifecycle | Shell |
| `autoabc_psr20` | Physical BD-J PSR20 hook management | Shell |
| `autoabc_virtual_hook` | Install guarded virtual preplay intercept | Shell |
| `preplay_virtual.sh` | Synchronous virtual-region decision | Shell |
| `autoabc_virtual_restore` | Maintain/restore virtual region during source lifecycle | Shell |
| `autoabc_virtual_off_pass` | Preserve native virtual PSR20 calls when ISO/BDMV selection is disabled | Shell |
| `start.sh` / `stop.sh` | Daemon start/stop logic | Shell |
| `status.sh` / `autoabcctl` | Read operational state | Shell |
| `config.sh` | Strict parsing of `ISO_BDMV` | Shell |
| `hook/*.bin` | Exact code signatures, RAM patch data and mailbox values | Opaque binary; rights not cleared for repo |

The public-source snapshot contains the exact shell files and launcher scripts, but not the ELF or opaque hook binary build inputs. The two sealed archives preserve those inputs for private review pending clearance. See [build and provenance](../BUILD_AND_PROVENANCE.md).

## Physical Blu-ray disc path

1. The physical disc watcher observes the current source and obtains the player process safely.
2. Fast/HDMV detection handles supported control-flow restrictions and chooses among A/B/C when justified.
3. BD-J fallbacks inspect bytecode/configuration and the player PSR20 region request. A patched PSR20 getter can use a mailbox without requiring the same value to persist in the global CBR.
4. An independent physical BD-J playback-state hold avoids restoring global region during a confirmed playing session (within the documented HBI heuristic); it restores stock in observed STOP/HOME/EJECT conditions.

## Virtual ISO and BDMV path (`ISO_BDMV=1`)

1. ISO is recognized via the known loop-mount session and BDMV folders via the native link/source path.
2. A checked synchronous player hook invokes `preplay_virtual.sh` at the correct setup point. This avoids the race of an asynchronous mount watcher.
3. The script confirms source integrity and player PID, runs core detection, optional HDMV validation/fallback and BD-J callgraph if the region is unresolved.
4. Just before applying an answer it checks that the source is still the same. The virtual restore daemon maintains the session and then restores STOCK.

With `ISO_BDMV=0`, autoABC intentionally does not enable those virtual region hooks/daemons. The physical path keeps running; the virtual pass-through guard avoids erroneously supplying a physical PSR20 answer to virtual playback. **PASS means call through to the original region getter**, not all regions automatically permitted.

## Scope and limitations

- A global CBR value, a BD-J PSR20 mailbox answer and the user's persisted stock region are distinct state variables.
- The STOP/HOME inference is title-dependent. HBI decoder fields and process-thread counts are heuristics, not a formally documented universal playback state API.
- Hard-coded exact signature samples are safeguards, but not proof that every custom firmware image is compatible.
- Physical and virtual playback can overlap at the UI layer; unsupported mixed-source edge cases still need hardware testing.

Supporting project evidence: [Evidence register](EVIDENCE_REGISTER.md), [Development history](DEVELOPMENT_HISTORY.md).
