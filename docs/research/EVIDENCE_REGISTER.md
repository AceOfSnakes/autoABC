# Evidence register: source chain for this release

**Identity rule:** The Chat 1-4 numbers below are derived from the **uploaded filenames**, even if an internal heading inside the archived document identifies itself as a different chat. No obsolete build names are used as public autoABC releases.

| Evidence | Primary source file | SHA-256 | Relevant scope |
| --- | --- | --- | --- |
| [D1] | `autoABC_CHAT1_FULL_RELEASE_HANDOFF_20261020.md` | `c21135dd47cf67fe221b211cd6943f8d4043752598a36b2c492482b1cbe8f79c` | CBR/PSR20 discovery, semantic HDMV and BD-J detection, first title corpus |
| [D2] | `autoABC_CHAT2_COMPLETE_DEVELOPMENT_DOCUMENTATION.md` | `c08c304fcb10a5010636cdc4738bd058aee674c303261f7479d829bc54762bdf` | Virtual source timing, process suspension failures, sync preplay hook |
| [D3] | `autoABC_CHAT3_GITHUB_RELEASE_HANDOFF.md` | `971395461fbfb0249afecd9fd63c4b3e331920b51cd79868fe56f6481b9f60f1` | Stable physical/virtual paths, PSR20 behavior, early-boot safety, installer evolution |
| [D4] | `autoABC_CHAT4_GITHUB_RELEASE_HANDOFF_20261020.md` | `edbbe05355a4539828f05b6b611c28ddb3a40bce1b8c264cdbf0da565542fec6` | HBI physical BD-J replay/restore, config, no cache, package validation and open hardware tests |

The archived original materials are a **private source record**, not included in the publicly proposed Git tree. The English research docs here are derived reports. Where a result cannot be verified from current sealed ZIPs, it is explicitly identified as a historical hardware report or inference from [D1]-[D4].

## Claim-to-evidence mapping

| Claim | Evidence |
| --- | --- |
| Blu-ray region can be selected in the running player without changing persistent stock | [D1] runtime state & physical proof of concept |
| Some A-only/B-only/A+B/B+C restrictions were correctly classified and played on original hardware | [D1] live validation and corpus; [D2] regression tests |
| BDMV region gate can arrive ~20 ms after observed source transition | [D2] dedicated BDMV timing trace |
| Example BD-J ISO detection core+callgraph work ~0.338+0.595 seconds, BDMV ~0.51+0.71 seconds | [D2] specific detector measurements |
| PSR20 mailbox and global CBR can temporarily disagree while a BD-J disc still plays | [D3] PSR20 / status discussion; [D4] physical disc trace |
| Physical BD-J playback-state holding worked on the tested original player | [D4] hardware-confirmed replay/STOP/HOME test |
| ISO/BDMV on/off selection worked in predecessor hardware testing | [D4] reported config test |
| Cache was deliberately removed, default ISO mode is enabled | [D4] final configuration decision; verified installer `AutoScript/config.ini` |
| Exactly 44 immutable runtime files plus 1 config | [D4] cleanup/QA; current installer nested manifest, independently verified in handoff |
| Exact final installer and uninstaller hashes | [D4] final artifact identifiers; independently recalculated against attached ZIPs |
| Latest final USB install/uninstall passed hardware | **Not supported; still an open acceptance item** [D4] |
| Rights to redistribute all native/hook binaries | **Not established in the supplied sources** [D4] |

## Outer ZIPs and independent archive identity

```text
c1fdddfcf88e4bebb3d200e58c7724c242c1326ce538cffad128b21067444dff  autoABC-1.0.0-install.zip
d13fa93bfd10cb21b4afc29bc272864c22a780ad09e767520cdeda5816469dd8  autoABC-1.0.0-uninstall.zip
```

Source filenames, document hashes and claimed observations are included so that a maintainer with access to the private archive can trace the original passages. No missing private log or original manufacturer permission is implied to exist in this repository.
