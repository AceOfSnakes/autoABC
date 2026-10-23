#!/bin/sh
# UOPfree ONE-SHOT RAM patch (from validated UOPfree RAM implementation).
# Dedicated process, unrelated to autoABC's region services or hook lifecycle.
# Only the discovery of the currently running RU-JB player has been extended.
BASE='/mnt/ubi_boot/autoABC'
BB="$BASE/bin/busybox"
PROC_ROOT=/proc
EXPECTED_SIZE=19400116
CODE_SKIP=$((0x001527A0 / 4))
DATA_SKIP=$((0x01281638 / 4))
EXPECTED_CODE=35f286e7cbf006fe00970221
MAX_WAIT=120
LOCK=/tmp/autoabc_uopfree_oneshot.lock
CANCEL="$BASE/uopfree.cancel"
PIDFILE="$BASE/uopfree.pid"
check_cancel(){ [ ! -e "$CANCEL" ] && [ ! -L "$CANCEL" ] || fail UNINSTALL_REQUESTED; }
log(){ printf 'UOPfree_1.1.0 %s\n' "$*"; }
fail(){ log "ABORT reason=$1"; exit 1; }
[ -x "$BB" ] && [ ! -L "$BB" ] || fail PRIVATE_BUSYBOX_UNAVAILABLE
[ -d "$PROC_ROOT" ] || fail PROCFS_UNAVAILABLE
# One attempt at a time. Never wait in an OPPO boot/launcher process.
if ! mkdir "$LOCK" 2>/dev/null; then
    log 'SKIP other UOPfree attempt already running'
    exit 0
fi
printf '%s\n' "$$" > "$PIDFILE" || { rmdir "$LOCK" 2>/dev/null || :; fail PIDFILE_UNAVAILABLE; }
cleanup_uop(){
    if [ "$(cat "$PIDFILE" 2>/dev/null)" = "$$" ]; then rm -f "$PIDFILE"; fi
    rmdir "$LOCK" 2>/dev/null || :
}
trap cleanup_uop 0
trap 'exit 1' 1 2 3 15
read_hex(){
    "$BB" dd if="$MEM" bs=4 skip="$1" count="$2" 2>/dev/null |
        "$BB" hexdump -v -e '1/1 "%02x"'
}
# A PID scan avoids the old hardcoded "/usr/local/bin/bdpprog.1" argv,
# which misses the separate jb_overlay V3 executable.
find_player(){
    COUNT=0; FOUND=
    for P_DIR in "$PROC_ROOT"/[0-9]*; do
        [ -r "$P_DIR/comm" ] || continue
        [ "$(cat "$P_DIR/comm" 2>/dev/null)" = 'bdpprog.1' ] || continue
        COUNT=$((COUNT + 1))
        FOUND="${P_DIR##*/}"
    done
    [ "$COUNT" -eq 1 ] || return 1
    printf '%s\n' "$FOUND"
}
check_cancel
log 'START mode=ONE_SHOT_RAM_ONLY'
i=0; P=
while [ "$i" -lt "$MAX_WAIT" ]; do
    check_cancel
    P="$(find_player)" || P=
    [ -n "$P" ] && [ -r "$PROC_ROOT/$P/maps" ] && break
    i=$((i + 1))
    "$BB" sleep 1
done
[ -n "$P" ] && [ -r "$PROC_ROOT/$P/maps" ] || fail PLAYER_NOT_FOUND
# Preserve the two-second initialization grace from the validated UOPfree implementation.
"$BB" sleep 2
check_cancel
[ "$(find_player)" = "$P" ] || fail PLAYER_CHANGED
EXE="$PROC_ROOT/$P/exe"
PLAYER="$($BB readlink "$EXE" 2>/dev/null)" || fail PLAYER_EXECUTABLE_UNAVAILABLE
case "$PLAYER" in
    /usr/local/bin/bdpprog.1|/mnt/rootfs_normal/usr/local/bin/bdpprog.1|/mnt/ubi_boot/jb_overlay/bdp/bdpprog.1) ;;
    *) fail PLAYER_PATH_NOT_SUPPORTED ;;
esac
SIZE="$($BB stat -L -c '%s' "$EXE" 2>/dev/null)"
[ "$SIZE" = "$EXPECTED_SIZE" ] || fail PLAYER_SIZE_MISMATCH
MAPS="$PROC_ROOT/$P/maps"
# Original RU-JB executable and BSS mapping shape from the validated UOPfree implementation.
"$BB" grep -Fq '00008000-011d8000 r-xp' "$MAPS" || fail CODE_MAP_MISMATCH
"$BB" grep -Fq '0127f000-01b0f000 rwxp' "$MAPS" || fail DATA_MAP_MISMATCH
# Verify the mapped player's known path, not just a same-named process.
"$BB" grep -Fq "$PLAYER" "$MAPS" || fail PLAYER_MAP_MISMATCH
check_cancel
MEM="$PROC_ROOT/$P/mem"
[ -r "$MEM" ] && [ -w "$MEM" ] || fail NO_RAM_ACCESS
CODE="$(read_hex "$CODE_SKIP" 3)"
[ "$CODE" = "$EXPECTED_CODE" ] || fail STOCK_CODE_SIGNATURE_MISMATCH
BEFORE="$(read_hex "$DATA_SKIP" 1)"
log "PID=$P STOCK_CHECK=OK VALUE_BEFORE=$BEFORE"
case "$BEFORE" in
    01000000) log 'RESULT=ALREADY_ENABLED'; exit 0 ;;
    00000000) ;;
    *) fail UNEXPECTED_UOP_VALUE ;;
esac
# Abort if a different player takes over or the target changes under us.
check_cancel
[ "$(find_player)" = "$P" ] || fail PLAYER_CHANGED_BEFORE_WRITE
[ "$(read_hex "$DATA_SKIP" 1)" = '00000000' ] || fail UOP_VALUE_CHANGED
check_cancel
if ! printf '\001\000\000\000' |
    "$BB" dd of="$MEM" bs=4 seek="$DATA_SKIP" count=1 conv=notrunc 2>&1; then
    fail RAM_WRITE_FAILED
fi
AFTER="$(read_hex "$DATA_SKIP" 1)"
log "VALUE_AFTER=$AFTER"
[ "$AFTER" = '01000000' ] || fail RAM_READBACK_MISMATCH
log 'RESULT=PASS RAM_ONLY_FILES_UNCHANGED'
exit 0
