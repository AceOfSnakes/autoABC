# Installer source layout

`install/` and `uninstall/` contain **different exact** AutoScript launchers and scripts. `read-only/` contains diagnostic and manual recovery scripts taken from the supplied installer ZIP.

- `install/AutoScript.TSS` and `install/autoABC-install.sh`: sealed installer bootstrap, checksum and firmware-signature validation, staging, rollback and wrapper management.
- `install/config.ini`: editable USB setting, default `ISO_BDMV=1`.
- `uninstall/AutoScript.TSS` and `uninstall/autoABC-uninstall.sh`: independent removal workflow with CRLF MTK launcher and guarded `brick_monitor` restoration.
- `read-only/CHECK_READONLY.sh`: **post-install** no-write installed-runtime verifier; not an all-firmware preflight.
- `read-only/UNINSTALL.sh`: original manually invoked emergency helper; not part of the normal AutoScript uninstall startup.

These exact files are source references. They are **not** a complete USB installer tree without the absent native ARM executables and required hook bytes. To install, use the sealed original USB ZIP and follow its documented procedure. The included `mkrelease.sh` does **not** create fresh binary payloads.
