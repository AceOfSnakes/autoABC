# Sources and technical references

The following external references describe established Blu-ray and OPPO UDP-203 behavior. **They do not describe, certify or endorse autoABC**. The implementation and hardware observations in this repository are based on the project's own development, tests and published research summaries.

## Blu-ray regions, playback formats and player behavior

1. **Sony Support — Region Codes for Blu-ray Discs.** https://www.sony.com/electronics/support/home-video-blu-ray-disc-players-recorders/bdp-s480/articles/00029369  
   Describes **Region A**, **Region B**, **Region C** and **Region ABC / region-free**. Also distinguishes the typical region-free behavior of UHD Blu-ray from standard Blu-ray.
2. **Blu-ray Disc Association — ROM2 Format Specification.** https://blu-raydisc.info/format-spec/rom2-spec.php  
   Explains that BD-ROM movie content uses **Region Playback Control (RPC)** and supports both **HDMV** and **BD-J** application formats.
3. **Blu-ray.org.uk — Player Status Registers (PSR).** https://www.blu-ray.org.uk/2024/03/psr.html  
   Technical secondary reference identifying PSR20 as the BD player-region register with values **1=A, 2=B, 4=C** and PSR19 as a separate country-code register. This is a reference overview, **not an official Blu-ray specification or certification**.
4. **OPPO Digital — UDP-203 Support and Firmware Information.** https://www.oppodigital.com/blu-ray-udp-203/blu-ray-udp-203-Support.aspx  
   Manufacturer support, firmware-version background and access to the user manual. The required **RU-JB 65-0131 jailbreak firmware** is a specific modified environment, not just the displayed official firmware number.
5. **OPPO Digital — UDP-203 User Manual.** https://download.oppodigital.com/UDP203/UDP-203_USER_MANUAL_ENGLISH_V1.1.pdf  
   Product playback, operation and region-management background. It is not a specification for autoABC or its runtime hooks.

## First-party engineering evidence

The autoABC project carried out its own firmware-interface analysis, HDMV and BD-J detection experiments, PSR20 observations, playback tests, negative controls, and virtual-media timing measurements. The primary internal development notes are maintained separately and have been **curated into public English technical reports**, rather than posted as unreviewed experimental logs.

- [Evidence register](research/EVIDENCE_REGISTER.md) — specific claims, method and qualification.
- [Region support](REGION_SUPPORT.md) — implementation coverage versus demonstrated hardware tests.
- [Test evidence](research/TEST_EVIDENCE.md) — representative Blu-ray editions, authoring strategies and limitations.
- [Research index](research/README.md) — architecture, design changes, failed approaches and measured timings.
- [Release verification](VERIFICATION.md) — packaging integrity and the maintainer's working-version confirmation.

Third-party references help explain the standard; they must not be mistaken for independent validation of the autoABC mod. Trademarks belong to their respective owners. External source links checked October 2026.
