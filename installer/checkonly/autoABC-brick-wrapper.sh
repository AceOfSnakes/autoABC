#!/bin/sh
# AUTOABC_EARLYBOOT_110: monitor-first, never wait in the 3-second overlay IR window.
# init.sh starts this binary in background and kills it after ~3 seconds.
BASE='/mnt/ubi_boot/autoABC'
REAL='/mnt/ubi_boot/jb_overlay/bin/brick_monitor.autoABC_real_v110'
log(){ printf 'OVERLAY_EARLYBOOT %s\n' "$*" >> "$BASE/earlyboot.log" 2>/dev/null || :; }
if [ -x "$BASE/start.sh" ]; then
    ( sh "$BASE/start.sh" >> "$BASE/boot.log" 2>&1 ) >/dev/null 2>&1 &
fi
if [ -x "$BASE/uopfree_launch.sh" ]; then
    ( sh "$BASE/uopfree_launch.sh" >> "$BASE/uopfree.log" 2>&1 ) >/dev/null 2>&1 &
fi
# Always hand over to the saved, SHA-verified original as quickly as possible.
# This is essential for the user's EJECT-to-KEY8 remap at boot.
if [ -x "$REAL" ]; then exec "$REAL" "$@"; fi
printf 'AUTOABC_FATAL_REAL_BRICK_MONITOR_MISSING\n' >> /tmp/jb_init.log
log 'FATAL_REAL_MONITOR_MISSING'
exit 127
