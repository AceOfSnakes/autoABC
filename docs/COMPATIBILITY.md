# Compatibility and known limitations

| Item | Status |
| --- | --- |
| Original OPPO UDP-203 | Target platform |
| RU-JB 65-0131 environment | Required, plus four matching live signatures |
| Live process `bdpprog.1` | Required during installation |
| Operating jailbreak overlay / `brick_monitor` | Required |
| Stock OPPO 65-0131 firmware without compatible jailbreak | **Not supported** |
| UDP-205, other models or clone media players | **Not supported / unverified** |
| Arbitrary modified player binaries or unknown early-boot wrappers | **Unsupported; refuse rather than guess** |
| Blu-ray physical HDMV / BD-J | Supported pathways, disc-specific results vary |
| ISO / BDMV automatic detection | Optional; enabled by default |
| DVD region changes | Not part of autoABC |
| Region-free behavior on all titles | Not guaranteed |

There is no firmware flash in this installer, but runtime process-memory writes and overlay early-boot modification are substantial changes. Matching the displayed firmware string alone is not enough. The installer checks four known code signatures and aborts if anything needed is absent, ambiguous or different.

## Playback limitations

- HDMV and BD-J do not implement region restrictions identically. Some BD-J titles ask for the system's PSR20 region during playback; others use different logic. A conservative `UNKNOWN` result is not treated as a universal bypass.
- The region shown in a global status view may differ from the region returned through the BD-J PSR20 gate. These are distinct observations, especially around session transitions.
- Physical BD-J STOP/HOME restoration uses a conservative playback-state heuristic tested with a specific disc. A different menu/background-video workload may present similar decoder states.
- For virtual BD-J media, region analysis can add visible loading time. Disable the optional virtual branch with `ISO_BDMV=0` if you prefer the firmware's ordinary ISO/BDMV behavior.
- The mod is not a copy-protection, AACS, UHD or Cinavia bypass and makes no claims about such mechanisms.

See [Research: observed title coverage](research/TEST_EVIDENCE.md) and [Verification](VERIFICATION.md).
