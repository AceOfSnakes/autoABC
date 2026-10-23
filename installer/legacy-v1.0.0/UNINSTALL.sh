#!/bin/sh
# Standalone manual removal. It does not change other jb_overlay components.
set -eu
U=/mnt/ubi_boot
D="$U/autoABC"
BIN="$U/jb_overlay/bin"
BM="$BIN/brick_monitor"
REAL="$BIN/brick_monitor.autoABC_real_v1"
BB="$BIN/busybox"
[ -x "$BB" ] || BB=/bin/busybox
TMP="$BIN/.brick_monitor.autoABC.uninstall.$$"
trap 'rm -f "$TMP"' 0
fail(){ echo "UNINSTALL=ABORTED: $*"; exit 1; }
[ ! -L "$D" ] || fail 'autoABC directory is a symlink'
[ ! -L "$BM" ] || fail 'brick_monitor is a symlink'
[ ! -L "$REAL" ] || fail 'saved brick_monitor is a symlink'
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
