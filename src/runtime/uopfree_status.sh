#!/bin/sh
# Read-only status for UOPfree; does not depend on any autoABC hook daemon.
BASE='/mnt/ubi_boot/autoABC'
BB="$BASE/bin/busybox"
echo '--- UOPFREE ---'
if [ ! -r "$BASE/uopfree.ini" ] || [ -L "$BASE/uopfree.ini" ]; then
    echo 'UOPFREE_CONFIG=UNKNOWN'; exit 1
fi
UOPCONF="$(cat "$BASE/uopfree.ini" 2>/dev/null)"
case "$UOPCONF" in
    UOPFREE=0) echo 'UOPFREE_CONFIG=0'; echo 'UOPFREE_STATE=DISABLED_BY_CONFIG'; exit 0 ;;
    UOPFREE=1) echo 'UOPFREE_CONFIG=1' ;;
    *) echo 'UOPFREE_CONFIG=INVALID'; echo 'UOPFREE_STATE=CONFIG_INVALID'; exit 1 ;;
esac
[ -x "$BB" ] && [ ! -L "$BB" ] || { echo 'UOPFREE_STATE=BUSYBOX_MISSING'; exit 1; }
if [ -e /mnt/ubi_boot/bluray_uop ] || [ -e /mnt/ubi_boot/UOPfree ]; then
    echo 'UOPFREE_STATE=EXTERNAL_MODULE_DETECTED'; exit 1
fi
P=''; COUNT=0
for PP in /proc/[0-9]*; do
    [ "$(cat "$PP/comm" 2>/dev/null)" = bdpprog.1 ] || continue
    COUNT=$((COUNT+1)); P="${PP##*/}"
done
[ "$COUNT" = 1 ] || { echo "UOPFREE_STATE=PLAYER_COUNT_$COUNT"; exit 1; }
EXE="/proc/$P/exe"
PLAYER="$("$BB" readlink "$EXE" 2>/dev/null)"
case "$PLAYER" in
    /usr/local/bin/bdpprog.1|/mnt/rootfs_normal/usr/local/bin/bdpprog.1|/mnt/ubi_boot/jb_overlay/bdp/bdpprog.1) ;;
    *) echo 'UOPFREE_STATE=PLAYER_PATH_NOT_SUPPORTED'; exit 1 ;;
esac
[ "$("$BB" stat -L -c '%s' "$EXE" 2>/dev/null)" = 19400116 ] || { echo 'UOPFREE_STATE=PLAYER_SIZE_MISMATCH'; exit 1; }
"$BB" grep -Fq '00008000-011d8000 r-xp' "/proc/$P/maps" 2>/dev/null || { echo 'UOPFREE_STATE=CODE_MAP_MISMATCH'; exit 1; }
"$BB" grep -Fq '0127f000-01b0f000 rwxp' "/proc/$P/maps" 2>/dev/null || { echo 'UOPFREE_STATE=DATA_MAP_MISMATCH'; exit 1; }
"$BB" grep -Fq "$PLAYER" "/proc/$P/maps" 2>/dev/null || { echo 'UOPFREE_STATE=PLAYER_MAP_MISMATCH'; exit 1; }
M="/proc/$P/mem"
[ -r "$M" ] || { echo 'UOPFREE_STATE=RAM_NOT_READABLE'; exit 1; }
CODE="$("$BB" dd if="$M" bs=4 skip=$((0x001527A0 / 4)) count=3 2>/dev/null | "$BB" hexdump -v -e '1/1 "%02x"')"
[ "$CODE" = 35f286e7cbf006fe00970221 ] || { echo 'UOPFREE_STATE=CODE_SIGNATURE_MISMATCH'; exit 1; }
V="$("$BB" dd if="$M" bs=4 skip=$((0x01281638 / 4)) count=1 2>/dev/null | "$BB" hexdump -v -e '1/1 "%02x"')"
echo "UOPFREE_PID=$P"
echo "UOPFREE_RAM_VALUE=$V"
case "$V" in
    01000000) echo 'UOPFREE_STATE=ACTIVE_RAM_VERIFIED'; exit 0 ;;
    00000000) echo 'UOPFREE_STATE=INACTIVE_RAM_VERIFIED'; exit 1 ;;
    *) echo 'UOPFREE_STATE=RAM_UNEXPECTED_OR_UNREADABLE'; exit 1 ;;
esac
