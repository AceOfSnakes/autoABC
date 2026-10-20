# Sources, evidence and acknowledgments

This release contains a curatorial **English** account of engineering work carried out across four development conversations. Statements based on original tests are labeled **internal evidence** below. They are not presented as independent third-party certification. The actual final install/uninstall ZIPs and their hashes are the primary evidence for packaged bytes.

## Primary development evidence

Source-document numbers follow the **CHAT1/CHAT2/CHAT3/CHAT4 in the uploaded filenames**, not the chat number that may appear in an old document heading.

- **[D1]** `autoABC_CHAT1_FULL_RELEASE_HANDOFF_20261020.md`: initial physical region interception, runtime CBR and PSR20 background, HDMV/BD-J detection, title corpus. SHA-256 `c21135dd47cf67fe221b211cd6943f8d4043752598a36b2c492482b1cbe8f79c`.
- **[D2]** `autoABC_CHAT2_COMPLETE_DEVELOPMENT_DOCUMENTATION.md`: virtual ISO/BDMV lifecycle, synchronous preplay, failed stop-based approaches, and detector timings. SHA-256 `c08c304fcb10a5010636cdc4738bd058aee674c303261f7479d829bc54762bdf`.
- **[D3]** `autoABC_CHAT3_GITHUB_RELEASE_HANDOFF.md`: stabilization, PSR20 and restore, filesystem/early-boot integration, risk and regression controls. SHA-256 `971395461fbfb0249afecd9fd63c4b3e331920b51cd79868fe56f6481b9f60f1`.
- **[D4]** `autoABC_CHAT4_GITHUB_RELEASE_HANDOFF_20261020.md`: physical BD-J playback-state improvement, final option choice, removal of cache, cleanup, hardening, final ZIP hashes, and remaining live-device release gates. SHA-256 `edbbe05355a4539828f05b6b611c28ddb3a40bce1b8c264cdbf0da565542fec6`.

The full historic source documents are preserved by the maintainer **outside the public repository**: they contain superseded commands, German notes, internal labels, paths and unreleased test references. The English research documents link back to [the evidence register](research/EVIDENCE_REGISTER.md) and intentionally avoid presenting historic experimental packages as public versions.

## Published technical / project references

- **[P1] OPPO Digital - UDP-203 support and firmware information.** https://www.oppodigital.com/blu-ray-udp-203/blu-ray-udp-203-Support.aspx . Official product and firmware reference; does **not** endorse or document this modification.
- **[P2] OPPO Digital - UDP-203 user manual (English).** https://download.oppodigital.com/UDP203/UDP-203_USER_MANUAL_ENGLISH_V1.1.pdf . Hardware/player operation and standard Blu-ray region context; does **not** specify autoABC internals.
- **[P3] fandangos/oppo-dv-mkv.** https://github.com/fandangos/oppo-dv-mkv . Independent OPPO-jailbreak mod illustrating AutoScript packaging, source organization, compatibility checks and uninstall practices. Inspiration, **not copied source or a technical dependency**.
- **[P4] ZeldaWWHDRecomp/ZeldaWWHDRecomp.** https://github.com/ZeldaWWHDRecomp/ZeldaWWHDRecomp . Reference for detailed reproducibility, legal asset separation, technical documentation and clear installation/build distinctions. Not a runtime dependency.
- **[P5] GitHub Docs - Managing releases in a repository.** https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository . Source archives associated with Git tags are different from attached, assembled AutoScript release ZIPs.

The original research, decisions and runtime measurements of autoABC come from **[D1]-[D4]**, not from any of the external repositories or official OPPO product documentation. Review third-party licensing and contributor attribution before release. External links checked October 20, 2026.

## Credit principles

- Recognize the project author/maintainer and contributors only after they approve their preferred public names.
- Credit the official hardware vendor without implying endorsement.
- Attribute outside analysis, tools and code separately if any third-party material is actually incorporated. No license is automatically granted by mentioning a project as inspiration.
- Do not distribute original OPPO firmware images, proprietary extracted assets, disc content or unique device secrets in issues, source or release attachments.
