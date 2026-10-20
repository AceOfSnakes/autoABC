# Physical BD-J: PSR20, playback-state holding and safe restoration

## Two observable region states

A physical Blu-ray Disc can use BD-J to read the player's region by requesting **PSR20**. The actual player's global Blu-ray region indicator (CBR) and the value supplied to the checked PSR20 getter are different states. During earlier real-disc testing, a known BD-J *Avatar* example received a compatible B through the PSR20 mailbox while global status later showed STOCK. Playback still worked. That was part of the original restoration policy, **not by itself a false region decision**. [D3], [D4].

The engineering goal for the current physical BD-J fallback was to keep the selected global runtime region during confirmed playback, then restore STOCK when the playback session really ends. This behavior was tested on an original OPPO with *Avatar*, including PLAY, STOP/HOME and replay. Do not extrapolate that a single decoder-state signature perfectly distinguishes every BD-J menu or every other title.

## Conservative HBI-based session heuristic

The final physical-disc shell logic observes a firmware playback-state block around `0x0128AA58` (within this exact supported binary), nominally every **200 ms**. It recognizes a narrow set of values at index 5 rather than treating arbitrary engine bits as authoritative:

- **Confirm PLAY** after at least two consecutive observations corresponding to selector/active/mode `1/1/1`.
- **Confirm STOP/HOME** after at least eight consecutive `0/0/0` observations and a minimum 20-thread reduction relative to confirmed active playback, or after a conservative fallback of 30 successive STOP observations (nominally about 6 seconds).
- Do **not** write the region on unknown/transition states.
- Fall back to a roughly **250-ms** grace restoration policy if HBI is unavailable at entry or repeatedly unreadable.
- Handle EJECT / disappearance of physical disc aliases independently, restoring global STOCK and resetting the session mailbox as needed.

This heuristic reduced premature global restoration during tested physical BD-J playback without inserting the same behavior into ordinary HDMV or ISO/BDMV code paths. [D4, physical playback-state investigation].

## Remaining uncertainty

Decoder fields are not an official title-state API. A background video/menu can produce PLAY-like HBI values after HOME; thread counts differ among discs. The archived evidence explicitly notes such a post-HOME PLAY-like state, so a broad guarantee of correct menu behavior would be unjustified. The sealed final installer has not received a complete hardware install/uninstall acceptance run, even though the relevant standalone physical-playback behavior was confirmed on the original player.

## What a meaningful new test should record

- Physical BD-J disc and actual allowed region; stock region before playback.
- Global CBR and PSR20 mailbox during playback, STOP, HOME, replay and EJECT.
- HBI state transitions and evidence that the active session is physical, not virtual.
- Whether another background player/menu state can cause a stale B reassertion.
- No unexpected or cumulative wrapper hooks after restart.

Sources: [D3] PSR20/CBR distinction and lifecycle; [D4] hardware HBI trace, confirmed behavior and unresolved menu-state caveats.
