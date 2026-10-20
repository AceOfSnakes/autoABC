# ISO and BDMV: source lifecycle, synchronous detection and loading time

**User-facing choice:** `ISO_BDMV=1` is the default. Users who prefer the player firmware's ISO/BDMV region behavior and want to avoid possible additional detection time on some BD-J titles can choose `ISO_BDMV=0`. Physical disc auto-region remains active in either case. 

## Why a naive watcher could not work

The player's BDMV folder source can change very shortly before the native setup routine reaches a region-sensitive decision. In one engineering trace, the link/source transition to the virtual-active flag was roughly **20 ms**. Meaningful detection on complex Java titles took hundreds of milliseconds. Therefore polling the filesystem and reacting later could correctly identify a region but still lose the timing race. Broadly stopping the whole player with `SIGSTOP` sometimes let the decision finish, but could also freeze the user interface or collide with file-descriptor state. ([engineering timing observations](EVIDENCE_REGISTER.md))

The selected design instead synchronizes only the relevant setup call through checked code signatures, allowing the detector to return before playback continues. Source identity is verified again before changing the region to avoid applying stale results to a newer mount.

## Measurements preserved from development

The source documentation records the following **individual measurements** on a difficult *Avatar* BD-J test case (not a statistical benchmark):

| Source | Core detector | BD-J callgraph | Approximate sum if sequentially used |
| --- | ---: | ---: | ---: |
| Blu-ray ISO | ~338 ms | ~595 ms | ~933 ms |
| BDMV folder | ~510 ms | ~710 ms | ~1,220 ms |

These figures describe measured **detection work** in a prior experimental environment. They are **not** a constant injected sleep, guaranteed additional wall-clock loading time, or proof that every title takes that long. Other validator work, I/O, title complexity, cache state outside autoABC, and UI behavior can change elapsed time. Many straightforward HDMV titles do not need the deep BD-J callgraph at all.

In `preplay_virtual.sh`, the current logic starts with `autoabc_detect` and may also run `autoabc_hdmv`; only unresolved cases continue to `autoabc_bdj`. The practical delay depends on which branch is actually followed. Do not infer a universal exactly 933-ms or 1,220-ms slowdown from the two sums.

## Why no persistent cache

A cache was tried during development and intentionally **excluded** from 1.0.0. It could skip some work after previous successful detection, but did not prove it could repair previously unknown discs, while introducing stale entries, fingerprint ambiguity and extra failure modes. Further improvements should focus on a validated detector/algorithm change rather than reintroducing a cache by default. 

## Practical configuration

```ini
ISO_BDMV=1
```

Set `0` if you prefer the normal virtual-media region handling and faster perceived starts on your particular BD-J ISO/BDMV library. Playback of ISO/BDMV itself is unaffected by the setting; it does not add universal region-freeness. Changes to the installed config require a full power cycle. [Configuration](../CONFIGURATION.md).

Sources of project measurements: [Evidence register](EVIDENCE_REGISTER.md) and [Test evidence](TEST_EVIDENCE.md).
