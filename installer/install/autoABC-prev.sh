#!/bin/sh
# AUTOABC_MKV_PREDECESSOR_110
# Dedicated predecessor for the unmodified oppo-dv-mkv v1.5.0/v1.6.0 wrapper.
# Non-blocking fail-open: background autoABC cannot delay the OPPO player.
BASE="/mnt/ubi_boot/autoABC"
PLAYER="/usr/local/bin/bdpprog.1"
if [ -x "$BASE/start.sh" ]; then
    ( sh "$BASE/start.sh" >> "$BASE/boot.log" 2>&1 ) &
fi
# UOPfree is independent of the region daemon, and always runs asynchronously.
# Waiting for bdpprog.1 here would otherwise deadlock the player launcher.
if [ -x "$BASE/uopfree_launch.sh" ]; then
    ( sh "$BASE/uopfree_launch.sh" >> "$BASE/uopfree.log" 2>&1 ) &
fi
exec "$PLAYER" "$@"
