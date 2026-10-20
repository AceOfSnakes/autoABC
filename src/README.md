# Runtime source inventory

The files in `runtime/` are exact copies of the **shell components** from the sealed 1.0.0 installer ZIP. Keep original filenames and operational markers; they are referenced by live scripts and manifests.

The complete sealed installer also contains the following statically linked ARM executables (distributed in the installer ZIP, not duplicated here):

```text
autoabc_detect
autoabc_hdmv
autoabc_bdj
autoabc_folder
```

And it contains multiple `AutoScript/autoABC/hook/*.bin` patch/profile/signature files. These files are firmware-specific release data rather than a complete native source build. Replacing these binaries with placeholders in an installer would render the pinned runtime manifest invalid. **Do not build a modified installer by blindly zipping `src/runtime/`.**

This source tree supports *inspection and review*, not an independently complete native rebuild. The release builder copies only fully verified sealed input ZIPs. See [Build and provenance](../docs/BUILD_AND_PROVENANCE.md) and [Legal](../docs/LEGAL_AND_LICENSING.md).
