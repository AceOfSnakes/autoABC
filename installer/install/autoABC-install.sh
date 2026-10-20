#!/bin/sh
# autoABC clean standalone installer. The only setting is ISO_BDMV=0 or 1.
VERSION="1.0.0"
SELF_PATH="$0"
SELF_DIR="${SELF_PATH%/*}"
[ "$SELF_DIR" = "$SELF_PATH" ] && SELF_DIR="."

# AutoScript.TSS copies us to /tmp. Locate this exact release on any OPPO USB mount.
S=""
AMB=0
for ID in /mnt/sd*/AutoScript/autoABC-release.id; do
    [ -f "$ID" ] || continue
    [ "$(cat "$ID" 2>/dev/null)" = "$VERSION" ] || continue
    CAND="${ID%/autoABC-release.id}"
    [ -f "$CAND/autoABC-install.sh" ] || continue
    [ -d "$CAND/autoABC" ] || continue
    if [ -z "$S" ]; then S="$CAND"; elif [ "$S" != "$CAND" ]; then AMB=1; fi
done
[ -n "$S" ] || { echo "autoABC $VERSION: USB payload not found" > /tmp/autoABC-bootstrap-error.txt; exit 1; }
USBROOT="${S%/*}"
U="/mnt/ubi_boot"
OVERLAY="$U/jb_overlay"
D="$U/autoABC"
LEGACY="$U/region_auto"
EXTCACHE="$U/region_auto_cache"
TARGET="$OVERLAY/bin/brick_monitor"
NEW_REAL="$OVERLAY/bin/brick_monitor.autoABC_real_v1"
OLD_REAL="$OVERLAY/bin/brick_monitor.regionauto_real_v039"
OLD_SAVED_WRAPPER="$OVERLAY/bin/brick_monitor.regionauto_wrapper_v039.saved"
BB="$OVERLAY/bin/busybox"; [ -x "$BB" ] || BB="/bin/busybox"
LOG="$USBROOT/autoABC.log"
RESULT="$USBROOT/autoABC-result.txt"
NEW_MARK="# AUTOABC_EARLYBOOT_V1"
OLD_MARK="# REGION_AUTO_V039_BRICKMON_WRAPPER"
TMPD="$U/.autoABC.new.$$"
OLDD="$U/.autoABC.old.$$"
TMPW="$OVERLAY/bin/.brick_monitor.autoABC.$$"
WRAP_BAK="$OVERLAY/bin/.brick_monitor.autoABC.prior.$$"
FW_TMP="/tmp/.autoabc_fwprobe.$$"
REAL_CREATED=NO
WRAP_CHANGED=NO
WRAP_BAK_PRESERVE=NO
BOOT_GUARD="/tmp/autoABC-installer-$VERSION.ran"
[ -e "$BOOT_GUARD" ] && exit 0
: > "$BOOT_GUARD" 2>/dev/null || :
exec >>"$LOG" 2>&1

echo "=== autoABC $VERSION $(date) uptime $(cut -d' ' -f1 /proc/uptime 2>/dev/null)s ==="
echo "MODE=USER_CONFIGURED_USB_INI"
echo "USB_SOURCE=$S"
echo "USB_ROOT=$USBROOT"
write_result(){ { echo "autoABC $VERSION - $1"; echo "$2"; echo "Details: autoABC.log"; } > "$RESULT"; "$BB" sync 2>/dev/null || sync; }
# Keep the previous runtime available until *final* verification succeeds.
SWAP_PHASE=NO
PREVIOUS_DIR=NO
cleanup_tmp(){ rm -rf "$TMPD" "$TMPW" 2>/dev/null; rm -f "$FW_TMP" 2>/dev/null; [ "$WRAP_BAK_PRESERVE" = YES ] || rm -f "$WRAP_BAK" 2>/dev/null; }
rollback_runtime() {
    [ "$SWAP_PHASE" = YES ] || return 0
    if [ "$PREVIOUS_DIR" = YES ] && [ -d "$OLDD" ]; then
        mv "$D" "$TMPD.failed" 2>/dev/null || :
        if mv "$OLDD" "$D" 2>/dev/null; then
            echo 'ROLLBACK_RUNTIME=RESTORED_PREVIOUS'
            rm -rf "$TMPD.failed" 2>/dev/null || :
        else
            echo "ROLLBACK_RUNTIME=FAILED; saved previous directory at $OLDD"
        fi
    elif [ "$PREVIOUS_DIR" = NO ]; then
        rm -rf "$D" 2>/dev/null || :
        echo 'ROLLBACK_RUNTIME=REMOVED_FAILED_FRESH_INSTALL'
    fi
}
rollback_wrapper() {
    [ "$WRAP_CHANGED" = YES ] || return 0
    if [ -s "$WRAP_BAK" ] && mv -f "$WRAP_BAK" "$TARGET"; then
        WRAP_CHANGED=NO
        echo "ROLLBACK_EARLYBOOT=RESTORED"
    else
        WRAP_BAK_PRESERVE=YES
        echo "ROLLBACK_EARLYBOOT=FAILED; backup retained at $WRAP_BAK"
    fi
}
fail(){
    echo "FAILED: $*"
    rollback_wrapper
    rollback_runtime
    # Only discard a newly-created real backup if its original target is safely restored.
    if [ "$REAL_CREATED" = YES ] && [ "$WRAP_BAK_PRESERVE" != YES ]; then
        if [ "$WRAP_CHANGED" = NO ] || "$BB" cmp -s "$TARGET" "$WRAP_BAK" 2>/dev/null; then
            rm -f "$NEW_REAL"
            echo 'ROLLBACK_NEW_BACKUP=REMOVED'
        fi
    fi
    write_result "FAILED" "$*"
    cleanup_tmp
    exit 1
}
is_new_wrapper(){ [ -f "$TARGET" ] && grep -Fq "$NEW_MARK" "$TARGET" 2>/dev/null; }
is_old_wrapper(){ [ -f "$TARGET" ] && grep -Fq "$OLD_MARK" "$TARGET" 2>/dev/null; }
is_wrapper_file(){ [ -f "$1" ] && { grep -Fq "$NEW_MARK" "$1" 2>/dev/null || grep -Fq "$OLD_MARK" "$1" 2>/dev/null; }; }
valid_real(){ [ -x "$1" ] && [ -s "$1" ] && ! is_wrapper_file "$1"; }
copy_exact(){ cp -p "$1" "$2" || return 1; "$BB" cmp -s "$1" "$2"; }
eject_success(){
    C=""
    for X in /usr/local/bin/cliprog /usr/bin/cliprog /bin/cliprog; do [ -x "$X" ] && { C="$X"; break; }; done
    [ -n "$C" ] || { echo "WARNING: cliprog missing; install succeeded but tray signal unavailable"; return 1; }
    echo "SUCCESS_SIGNAL: drv.ir.rx.sq 0xaf000"
    printf 'drv.ir.rx.sq 0xaf000\nquit\n' | "$C" >/dev/null 2>&1
}

[ "$AMB" = 0 ] || fail "multiple matching $VERSION USB payloads found"
[ -d "$U" ] || fail "$U missing"
[ -x "$BB" ] || fail "jb_overlay busybox missing"
[ -x "$TARGET" ] || fail "jb_overlay brick_monitor missing"
[ -f "$S/autoABC/SHA256SUMS" ] || fail "payload manifest missing"

# Pinned manifest + complete hash check BEFORE stopping active daemons.
# Also prevents a modified manifest from adding stray files to the allowlist.
MANIFEST_SHA="bdf2606dcfa93eefd181f0cc7a2310322352825f95f33980c970cadcd9873d7b"
SOURCE_MANIFEST="$S/autoABC/SHA256SUMS"
[ "$("$BB" sha256sum "$SOURCE_MANIFEST" 2>/dev/null | "$BB" awk '{print $1}')" = "$MANIFEST_SHA" ] || fail "unexpected payload manifest"
BAD=0
COUNT=0
while read SUM FILE; do
    [ -n "$SUM" ] || continue
    COUNT=$((COUNT+1))
    [ -f "$S/autoABC/$FILE" ] || { echo "missing payload: $FILE"; BAD=1; continue; }
    GOT="$("$BB" sha256sum "$S/autoABC/$FILE" 2>/dev/null | "$BB" awk '{print $1}')"
    [ "$GOT" = "$SUM" ] || { echo "payload hash mismatch: $FILE"; BAD=1; }
done < "$SOURCE_MANIFEST"
[ "$BAD" = 0 ] && [ "$COUNT" -eq 44 ] || fail "payload integrity check failed (count=$COUNT)"

# The editable USB config.ini is deliberately not part of either hash manifest.
# Its *content* is strictly parsed by the trusted, pinned runtime parser.
# It is authoritative on EVERY install/reinstall, including upgrades.
SOURCE_CONFIG="$S/config.ini"
[ -f "$SOURCE_CONFIG" ] || fail "AutoScript/config.ini missing; expected ISO_BDMV=0 or ISO_BDMV=1"
REQUESTED_ISO="$(sh "$S/autoABC/config.sh" get-iso "$SOURCE_CONFIG" 2>/dev/null)" || fail "AutoScript/config.ini is invalid; expected exactly one ISO_BDMV=0/1"
case "$REQUESTED_ISO" in 0|1) ;; *) fail "unexpected ISO_BDMV value on USB";; esac
echo "USB_CONFIGURATION=VALID ISO_BDMV=$REQUESTED_ISO"
# The loader target is version-independent. Do not require a brick_monitor hash.
# A symlink can redirect backups/restores outside jb_overlay: never overwrite one.
[ ! -L "$TARGET" ] || fail "brick_monitor is a symlink; manual compatibility review required"
[ ! -L "$NEW_REAL" ] || fail "autoABC real brick_monitor backup is a symlink"
[ ! -L "$OLD_REAL" ] || fail "legacy real brick_monitor backup is a symlink"
[ ! -L "$D" ] || fail "autoABC runtime is a symlink"
[ ! -L "$LEGACY" ] || fail "legacy RegionAuto directory is a symlink"
# Refuse a mixed/nested marker or a renamed/repointed known wrapper.
if is_new_wrapper && is_old_wrapper; then
    fail "multiple earlyboot wrapper markers found; possible wrapper chain"
fi
ACTIVE_OWNER=UNOWNED
if is_new_wrapper; then
    grep -Fq 'BASE="/mnt/ubi_boot/autoABC"' "$TARGET" || fail "modified autoABC earlyboot BASE"
    grep -Fq 'REAL="/mnt/ubi_boot/jb_overlay/bin/brick_monitor.autoABC_real_v1"' "$TARGET" || fail "modified autoABC earlyboot REAL"
    grep -Fq 'exec "$REAL" "$@"' "$TARGET" || fail "modified autoABC earlyboot exec"

    ACTIVE_OWNER=AUTOABC
    valid_real "$NEW_REAL" || fail "active autoABC wrapper: saved real brick_monitor missing/invalid"
    [ -d "$D" ] && [ -x "$D/stop.sh" ] || fail "autoABC wrapper without expected runtime/stop.sh"
elif is_old_wrapper; then
    grep -Fq 'BASE="/mnt/ubi_boot/region_auto"' "$TARGET" || fail "modified legacy earlyboot BASE"
    grep -Fq 'REAL="/mnt/ubi_boot/jb_overlay/bin/brick_monitor.regionauto_real_v039"' "$TARGET" || fail "modified legacy earlyboot REAL"
    grep -Fq 'exec "$REAL" "$@"' "$TARGET" || fail "modified legacy earlyboot exec"
    ACTIVE_OWNER=LEGACY
    valid_real "$OLD_REAL" || fail "active RegionAuto wrapper: saved real brick_monitor missing/invalid"
    [ -d "$LEGACY" ] && [ -x "$LEGACY/stop.sh" ] || fail "legacy wrapper without supported runtime/stop.sh"
    [ ! -e "$D" ] || fail "autoABC runtime exists alongside legacy wrapper; inspect manually"
    [ ! -e "$NEW_REAL" ] || fail "unowned autoABC real backup exists during legacy migration"
else
    [ -x "$TARGET" ] && [ -s "$TARGET" ] || fail "brick_monitor missing/invalid"
    is_wrapper_file "$TARGET" && fail "unsupported brick_monitor wrapper"
    [ ! -e "$NEW_REAL" ] || fail "orphaned autoABC brick_monitor backup; manual recovery required"
    [ ! -e "$D" ] || fail "unowned autoABC runtime directory; manual recovery required"
    [ ! -e "$LEGACY" ] || fail "legacy RegionAuto directory without an active known wrapper"
    # A previously unknown shell launcher may be a foreign wrapper. We do not
    # wrap it automatically; native executables remain hash-agnostic.
    HEAD2="$("$BB" dd if="$TARGET" bs=1 count=2 2>/dev/null | "$BB" hexdump -v -e '1/1 "%02x"' 2>/dev/null)"
    [ "$HEAD2" != 2321 ] || fail "unknown script brick_monitor; possible foreign wrapper"
fi
echo "EARLYBOOT_OWNER=$ACTIVE_OWNER BRICK_MONITOR_HASH_RESTRICTION=NONE"

# This USB AutoScript is dispatched by the player itself. Verify its live
# firmware code BEFORE stopping a running mod, replacing any file or hook.
# Use four unchanged firmware instruction/data signatures that the existing
# PSR20 and ISO/BDMV hook daemons already require. No full-ELF SHA whitelist.
P_COUNT=0
PLAYER_PID=""
for PP in /proc/[0-9]*; do
    [ -r "$PP/comm" ] || continue
    if [ "$(cat "$PP/comm" 2>/dev/null)" = bdpprog.1 ]; then
        P_COUNT=$((P_COUNT+1))
        PLAYER_PID="${PP##*/}"
    fi
done
[ "$P_COUNT" -eq 1 ] || fail "expected exactly one running bdpprog.1 for firmware preflight; found $P_COUNT"
[ -r "/proc/$PLAYER_PID/mem" ] || fail "cannot read bdpprog.1 memory for firmware preflight"
firmware_matches(){
    ADDR="$1"; LEN="$2"; EXPECTED="$3"
    "$BB" dd if="/proc/$PLAYER_PID/mem" of="$FW_TMP" bs=1 skip="$ADDR" count="$LEN" 2>/dev/null || return 1
    "$BB" cmp -s "$FW_TMP" "$S/autoABC/hook/$EXPECTED"
}
firmware_matches 198392 12 sig_access_plt_12.bin || fail "unsupported player: access PLT signature (0x000306f8)"
firmware_matches 207180 12 sig_usleep_plt_12.bin || fail "unsupported player: usleep PLT signature (0x0003294c)"
firmware_matches 10615650 20 sig_bdmv_real_ln_call.bin || fail "unsupported player: BDMV call site (0x00a1fb62)"
firmware_matches 29378036 26 sig_iso_mount.bin || fail "unsupported player: ISO mount signature (0x01c045f4)"
rm -f "$FW_TMP"
echo "FIRMWARE_PREFLIGHT=PASS player_pid=$PLAYER_PID signatures=4 target=RU-JB_65-0131"
# Only now touch persistent storage, after validating firmware and ownership.
touch "$U/.autoABC-write-test" 2>/dev/null || fail "$U not writable"
rm -f "$U/.autoABC-write-test"

# Stage ONLY files explicitly listed in the release manifest. On macOS,
# FAT/exFAT USB drives can gain AppleDouble (._*) and .DS_Store files;
# those files are intentionally NEVER copied to internal storage.
[ ! -e "$OLDD" ] || fail "stale backup directory $OLDD; inspect manually"
rm -rf "$TMPD"
mkdir -p "$TMPD/hook" || fail "creating staging directory"
cp "$SOURCE_MANIFEST" "$TMPD/SHA256SUMS" || fail "copying pinned manifest"
while read SUM FILE; do
    [ -n "$SUM" ] || continue
    case "$FILE" in
        hook/*) ;;             # hook directory already created
        */*|.*|*..*|*\\*|*' '*) fail "unsafe manifest path: $FILE" ;;
        *) ;;
    esac
    cp "$S/autoABC/$FILE" "$TMPD/$FILE" || fail "copying allowlisted payload: $FILE"
    GOT="$("$BB" sha256sum "$TMPD/$FILE" 2>/dev/null | "$BB" awk '{print $1}')"
    [ "$GOT" = "$SUM" ] || fail "staged payload mismatch: $FILE"
done < "$SOURCE_MANIFEST"
"$BB" cmp -s "$SOURCE_MANIFEST" "$TMPD/SHA256SUMS" || fail "staged manifest mismatch"
cp "$SOURCE_CONFIG" "$TMPD/config.ini" || fail "copying USB configuration"
"$BB" cmp -s "$SOURCE_CONFIG" "$TMPD/config.ini" || fail "copied USB configuration mismatch"
STAGED_ISO="$(sh "$TMPD/config.sh" get-iso "$TMPD/config.ini" 2>/dev/null)" || fail "staged USB configuration invalid"
[ "$STAGED_ISO" = "$REQUESTED_ISO" ] || fail "USB configuration changed during installation"
echo "CONFIG_SOURCE=USB ISO_BDMV=$STAGED_ISO"
# FAT/exFAT may not preserve executable bits; restore them on stage.
chmod 755 "$TMPD"/* "$TMPD"/hook/* 2>/dev/null || :
chmod 644 "$TMPD/config.ini" "$TMPD/SHA256SUMS" || fail "setting metadata permissions"
[ -x "$TMPD/start.sh" ] || fail "start.sh missing"
[ -x "$TMPD/autoabc_disc" ] || fail "autoabc_disc missing"
[ -x "$TMPD/autoabc_psr20" ] || fail "PSR20 hook daemon missing"
[ -x "$TMPD/autoabc_virtual_hook" ] || fail "virtual hook daemon missing"
[ -x "$TMPD/autoabc_virtual_restore" ] || fail "virtual restore daemon missing"
[ -x "$TMPD/folderd_launcher.sh" ] || fail "folder daemon missing"
[ -x "$TMPD/config.sh" ] && [ -x "$TMPD/autoabc_virtual_off_pass" ] || fail "config/passguard scripts missing"
"$TMPD/config.sh" check "$TMPD/config.ini" >/dev/null 2>&1 || fail "staged config invalid"

# Destructive work starts only after every read-only check and full staging.
# Stop only the installation whose active earlyboot owner we have verified.
case "$ACTIVE_OWNER" in
    AUTOABC) "$D/stop.sh" || fail "current autoABC stop failed" ;;
    LEGACY) "$LEGACY/stop.sh" || fail "current RegionAuto stop failed" ;;
    UNOWNED) : ;;
esac
"$BB" usleep 400000 2>/dev/null || :
for P in /proc/[0-9]*; do
    [ -r "$P/cmdline" ] || continue
    C="$(tr '\000' ' ' < "$P/cmdline" 2>/dev/null)"
    case "$C" in *"$U/autoABC/"*|*"$U/region_auto/"*) fail "old mod process still running: ${P##*/}:$C";; esac
done

if [ -d "$D" ]; then mv "$D" "$OLDD" || fail "saving previous autoABC"; PREVIOUS_DIR=YES; fi
if ! mv "$TMPD" "$D"; then [ -d "$OLDD" ] && mv "$OLDD" "$D"; fail "activating runtime"; fi
SWAP_PHASE=YES
"$BB" sync 2>/dev/null || sync

# Preserve the exact existing jb_overlay brick_monitor, independent of overlay version/hash.
if [ "$ACTIVE_OWNER" = AUTOABC ]; then
    valid_real "$NEW_REAL" || fail "autoABC wrapper present but saved real brick_monitor invalid"
elif [ "$ACTIVE_OWNER" = LEGACY ]; then
    valid_real "$OLD_REAL" || fail "legacy RegionAuto wrapper present but saved real brick_monitor invalid"
    copy_exact "$OLD_REAL" "$NEW_REAL.tmp" || fail "migrating legacy brick_monitor"
    mv -f "$NEW_REAL.tmp" "$NEW_REAL" || fail "activating migrated brick_monitor"
    REAL_CREATED=YES
else
    [ -x "$TARGET" ] && [ -s "$TARGET" ] || fail "brick_monitor invalid"
    is_wrapper_file "$TARGET" && fail "unsupported wrapper state"
    copy_exact "$TARGET" "$NEW_REAL.tmp" || fail "saving current brick_monitor"
    mv -f "$NEW_REAL.tmp" "$NEW_REAL" || fail "activating saved brick_monitor"
    REAL_CREATED=YES
fi

copy_exact "$TARGET" "$WRAP_BAK" || fail "backing up active earlyboot wrapper"
cat > "$TMPW" <<'WRAP'
#!/bin/sh
# AUTOABC_EARLYBOOT_V1
BASE="/mnt/ubi_boot/autoABC"
REAL="/mnt/ubi_boot/jb_overlay/bin/brick_monitor.autoABC_real_v1"
LOG="/tmp/jb_init.log"
if [ -x "$BASE/start.sh" ]; then
    echo "AUTOABC_EARLYBOOT_START" >> "$LOG" 2>&1
    "$BASE/start.sh" >/tmp/autoABC_earlyboot.log 2>&1
fi
if [ -x "$REAL" ]; then
    exec "$REAL" "$@"
fi
echo "AUTOABC_FATAL_REAL_BRICK_MONITOR_MISSING" >> "$LOG" 2>&1
exit 127
WRAP
chmod 755 "$TMPW" || fail "chmod earlyboot wrapper"
mv -f "$TMPW" "$TARGET" || fail "installing earlyboot wrapper"
WRAP_CHANGED=YES
"$BB" sync 2>/dev/null || sync

# Final persistent verification. Do not start runtime now; reboot tests the normal earlyboot path.
grep -Fq "$NEW_MARK" "$TARGET" || fail "earlyboot verification failed"
valid_real "$NEW_REAL" || fail "saved real brick_monitor verification failed"
[ -x "$D/start.sh" ] && [ -x "$D/autoabc_disc" ] && [ -x "$D/autoabc_psr20" ] && [ -x "$D/autoabc_virtual_hook" ] && [ -x "$D/preplay_virtual.sh" ] || fail "runtime verification failed"
[ -f "$D/config.ini" ] && [ -x "$D/config.sh" ] || fail "configuration missing"
"$D/config.sh" check "$D/config.ini" >/dev/null 2>&1 || fail "configuration invalid"
[ "$("$D/config.sh" get-iso "$D/config.ini" 2>/dev/null)" = "$REQUESTED_ISO" ] || fail "installed configuration differs from USB request"
[ ! -e "$D/cache.sh" ] && [ ! -e "$D/cache" ] || fail "obsolete files present"
"$BB" sync 2>/dev/null || sync
# Previous version deleted only after all verification gates succeeded.
rm -rf "$OLDD"
SWAP_PHASE=NO
WRAP_CHANGED=NO

# Never delete legacy or unrelated directories during a public installation.
# For an owned legacy migration, the inactive files and original legacy backup
# are deliberately retained for independent/manual review after a successful boot.
# The new wrapper is the only active earlyboot owner.
echo "LEGACY_FILES=LEFT_UNTOUCHED"

echo "INSTALLED autoABC $VERSION (firmware signatures verified; physical BD-J/HBI; ISO_BDMV=$REQUESTED_ISO from USB)"
write_result "INSTALLED" "autoABC installed with ISO_BDMV=$REQUESTED_ISO from AutoScript/config.ini. Remove installer USB and power-cycle."
"$BB" sleep 1 2>/dev/null || sleep 1
eject_success || :
"$BB" sync 2>/dev/null || sync
cleanup_tmp
exit 0
