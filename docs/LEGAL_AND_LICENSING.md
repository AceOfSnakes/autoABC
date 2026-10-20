# Copyright, licenses and distribution boundary

This is a **pre-publication gate**, not legal advice. The provided installer contains original shell scripts **and** statically linked ARM executables, code-signature samples, hook payloads and binary fragments whose complete provenance and redistribution rights have not been confirmed in the supplied evidence. OPPO firmware itself is proprietary. It would be incorrect to assign an open-source license automatically to every file in an archive just because it is technically possible to extract it.

The current public-source draft therefore **excludes** native ARM executables and opaque hook binaries. The full original installation and removal ZIPs are preserved byte-for-byte in the separate **private handoff's `release-assets/`**, but **must not be published publicly without a permissions/provenance review**.

Before publication the maintainer should:

1. Identify author(s) and rights holders of the project's own shell scripts, runtime utilities and binary payloads.
2. Identify any OPPO-derived firmware instructions, patched executables, data tables, or third-party libraries/tools; determine what is legally redistributable in the intended jurisdiction.
3. Select a license for the parts whose rights can genuinely be granted, and include third-party notices/licenses as applicable. This handoff does not fabricate a grant.
4. For nonredistributable inputs, replace distribution with a documented, independently verified **local patch/build workflow** using legitimately obtained original files where legally permitted. A checksum-only copy script is not a substitute for that build.
5. Remove credentials, device-specific identifiers, NAND dumps, proprietary player executables and copyrighted media from public commits, release assets and attached bug reports.
6. Decide whether public release is appropriate after verifying the above. A generic use-at-your-own-risk notice is not a grant of redistribution rights.

The public repository contains `LICENSE-STATUS.md` instead of claiming an unapproved license. After rights clearance, replace it with an appropriate actual `LICENSE` and corresponding notices. Until then, **publication is pending** even if functional hardware tests pass.
