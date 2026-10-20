# Copyright, licenses and distribution status

autoABC is an independent community modification. The source repository and the downloadable release archives have different contents and therefore different licensing and provenance considerations. This document records the current state; it is **not legal advice** or a grant of rights.

## What is currently available

- **Repository:** readable shell-side runtime components, AutoScript launchers, installer/uninstaller scripts, documentation and offline verification tools. It does **not** contain a complete source-to-binary build chain for every native ARM or hook component.
- **GitHub release `v1.0.0`:** separate install and uninstall ZIPs containing the runtime payload, including compiled/native components. They are attached to the release even though the repository does not contain all of their build inputs.
- **Distribution status:** the release files are attached to GitHub. Repository visibility or the ability to download them does **not** by itself establish permission for public redistribution.

## Rights and provenance

Some native executables, hooks, code-signature samples or binary fragments have not yet been traced to a fully documented authorship and redistribution grant. OPPO firmware is proprietary. Publishing source files or attaching an archive to a release does not, by itself, make those files open source.

No project-wide open-source license has been assigned; see [LICENSE-STATUS.md](../LICENSE-STATUS.md). A general disclaimer or a successful hardware test is not a substitute for permission to redistribute third-party or firmware-derived code.

## Rights review for public distribution

1. Identify authors and rights holders of the project's scripts, utilities and compiled/native components.
2. Review any firmware-derived instructions, embedded data, third-party libraries and modified binaries for redistribution restrictions in the intended jurisdiction.
3. Choose a license for material the maintainer is authorized to license; include applicable third-party licenses and notices, and clearly exclude material for which such a grant cannot be made.
4. For components that cannot be redistributed, consider a documented local patch or build process using legitimately obtained inputs, where legally permitted. The existing checksum-and-copy workflow does **not** compile native code.
5. Check published files and bug-report guidance for credentials, machine-specific data, dumps, copyrighted media and other sensitive material.
6. Document the outcome of the rights review and any distribution restrictions before presenting the archives as cleared for public redistribution.

## Practical distinction

The `v1.0.0` install and uninstall ZIPs are **present** on GitHub; their presence should not be described as a future plan or as proof of distribution authorization. The outstanding issue is the provenance and permission review for any **public** distribution of all included components.
