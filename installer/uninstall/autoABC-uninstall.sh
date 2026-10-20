#!/bin/sh
# autoABC separate USB AutoScript uninstaller. NOT part of installer media.
set -eu
VERSION="1.0.0"
S=""
AMB=0
for ID in /mnt/sd*/AutoScript/autoABC-uninstall.id; do
    [ -f "$ID" ] || continue
    [ "$(cat "$ID" 2>/dev/null)" = "$VERSION" ] || continue
    CAND="${ID%/autoABC-uninstall.id}"
    [ -f "$CAND/autoABC-uninstall.sh" ] || continue
    if [ -z "$S" ]; then S="$CAND"; elif [ "$S" != "$CAND" ]; then AMB=1; fi
done
[ -n "$S" ] || { echo 'UNINSTALL=ABORTED: matching USB uninstall package not found' > /tmp/autoABC-uninstall-error.txt; exit 1; }
USBROOT="${S%/*}"
RESULT="$USBROOT/autoABC-uninstall-result.txt"
LOG="$USBROOT/autoABC-uninstall.log"
BOOT_GUARD="/tmp/autoABC-uninstaller-$VERSION.ran"
[ -e "$BOOT_GUARD" ] && exit 0
: > "$BOOT_GUARD" 2>/dev/null || :
exec >> "$LOG" 2>&1
write_result() {
    { echo "autoABC $VERSION - $1"; echo "$2"; echo 'Details: autoABC-uninstall.log'; } > "$RESULT"
    sync
}
echo "autoABC UNINSTALL $VERSION"
if [ "$AMB" != 0 ]; then
    write_result FAILED 'Multiple matching uninstall USB payloads'
    echo 'UNINSTALL=ABORTED: multiple uninstall USB payloads'
    exit 1
fi
U=/mnt/ubi_boot
D="$U/autoABC"
BIN="$U/jb_overlay/bin"
BM="$BIN/brick_monitor"
REAL="$BIN/brick_monitor.autoABC_real_v1"
BB="$BIN/busybox"
[ -x "$BB" ] || BB=/bin/busybox
TMP="$BIN/.brick_monitor.autoABC.uninstall.$$"
trap 'rm -f "$TMP"' 0
fail(){ echo "UNINSTALL=ABORTED: $*"; write_result FAILED "$*"; exit 1; }
[ ! -L "$D" ] || fail 'autoABC directory is a symlink'
[ ! -L "$BM" ] || fail 'brick_monitor is a symlink'
[ ! -L "$REAL" ] || fail 'original brick_monitor backup is a symlink'
[ -d "$D" ] || fail 'autoABC directory missing'
[ -x "$D/stop.sh" ] || fail 'autoABC stop script missing'
[ -x "$BB" ] || fail 'BusyBox missing'
[ -x "$BM" ] || fail 'brick_monitor missing'
[ -x "$REAL" ] && [ -s "$REAL" ] || fail 'saved original brick_monitor missing'
grep -Fq '# AUTOABC_EARLYBOOT_V1' "$BM" || fail 'unsupported active earlyboot wrapper'
grep -Fq '# REGION_AUTO_V039_BRICKMON_WRAPPER' "$BM" && fail 'mixed old/new earlyboot markers'
grep -Fq 'BASE="/mnt/ubi_boot/autoABC"' "$BM" || fail 'modified autoABC earlyboot BASE'
grep -Fq 'REAL="/mnt/ubi_boot/jb_overlay/bin/brick_monitor.autoABC_real_v1"' "$BM" || fail 'modified autoABC earlyboot REAL'
grep -Fq 'exec "$REAL" "$@"' "$BM" || fail 'modified autoABC earlyboot exec'
if grep -Fq '# AUTOABC_EARLYBOOT_V1' "$REAL" || grep -Fq '# REGION_AUTO_V039_BRICKMON_WRAPPER' "$REAL"; then
    fail 'backup is itself a wrapper'
fi
# Verify the original backup can be restored before stopping any processes.
cp -p "$REAL" "$TMP" || fail 'cannot stage original brick_monitor'
"$BB" cmp -s "$TMP" "$REAL" || fail 'original backup copy mismatch'
"$D/stop.sh" || fail 'autoABC stop returned failure'
"$BB" usleep 400000 2>/dev/null || :
for P in /proc/[0-9]*; do
    [ -r "$P/cmdline" ] || continue
    C="$(tr '\000' ' ' < "$P/cmdline" 2>/dev/null || :)"
    case "$C" in *"$D/"*) fail "autoABC process still running: ${P##*/}";; esac
done
# Atomic restoration. The saved real binary remains until verification passes.
mv -f "$TMP" "$BM" || fail 'failed restoring brick_monitor'
"$BB" cmp -s "$REAL" "$BM" || fail 'restored brick_monitor differs from backup'
"$BB" sync 2>/dev/null || sync
# After earlyboot no longer targets autoABC, remove only autoABC-owned files.
rm -rf "$D" || fail 'failed removing runtime directory'
rm -f "$REAL"
rm -f /tmp/ra /tmp/autoabc_active_iso /tmp/autoabc_disabled /tmp/autoabc_hook.state /tmp/autoabc_bdpprog.pid /tmp/autoabc_psr20_hook.state /tmp/autoabc_psr20_request.* /tmp/autoabc_virtual.state /tmp/autoabc_virtual.seq /tmp/autoabc_preplay.lock 2>/dev/null || :
"$BB" sync 2>/dev/null || sync
echo 'UNINSTALL=COMPLETE'
echo 'ORIGINAL_BRICK_MONITOR=RESTORED'
echo 'NEXT_ACTION=FULL_POWER_CYCLE'

write_result UNINSTALLED "Original brick_monitor restored and autoABC removed. Remove USB, then power-cycle."

# Use the same success feedback as the installer; no signal on failure.
eject_success(){
    C=""
    for X in /usr/local/bin/cliprog /usr/bin/cliprog /bin/cliprog; do
        [ -x "$X" ] && { C="$X"; break; }
    done
    [ -n "$C" ] || { echo "WARNING: cliprog missing; uninstall succeeded but tray signal unavailable"; return 1; }
    echo "SUCCESS_SIGNAL: drv.ir.rx.sq 0xaf000"
    printf 'drv.ir.rx.sq 0xaf000\nquit\n' | "$C" >/dev/null 2>&1
}
"$BB" sleep 1 2>/dev/null || sleep 1
eject_success || :
"$BB" sync 2>/dev/null || sync
exit 0
