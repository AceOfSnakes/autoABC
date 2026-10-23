#!/bin/sh
BASE="/mnt/ubi_boot/autoABC"
PIDFILE="$BASE/folderd.pid"
BB="/mnt/ubi_boot/autoABC/bin/busybox"
SELF="$$"
echo "$SELF" > "$PIDFILE"
cleanup() {
    P="$(cat "$PIDFILE" 2>/dev/null)"
    [ "$P" = "$SELF" ] && rm -f "$PIDFILE"
}
trap 'cleanup' 0
trap 'exit 0' 1 2 15
find_pid() {
    for p in /proc/[0-9]*; do
        [ -r "$p/comm" ] || continue
        [ "$(cat "$p/comm" 2>/dev/null)" = "bdpprog.1" ] && { echo "${p##*/}"; return 0; }
    done
    return 1
}
compatible_pid() {
    p="$1"
    [ -n "$p" ] || return 1
    [ "$(cat /proc/$p/comm 2>/dev/null)" = "bdpprog.1" ] || return 1
    grep -qi '^011d8000-0127f000 .*w' "/proc/$p/maps" 2>/dev/null || return 1
    [ -r "/proc/$p/mem" ] || return 1
    return 0
}
while :; do
    PID="$(find_pid)"
    compatible_pid "$PID" && break
    "$BB" usleep 5000 2>/dev/null || "$BB" sleep 1
done
# exec preserves this PID; the native folder daemon owns /mnt/link,
# region detection, virtual-active 0x01C05A04 lifecycle, and STOCK restore.
trap - 0 1 2 15
exec "$BASE/autoabc_folder" "/proc/$PID/mem"
