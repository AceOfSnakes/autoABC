#!/bin/sh
# autoABC integrity and runtime check. Reads files and process metadata only.
BASE=/mnt/ubi_boot/autoABC
TARGET=/mnt/ubi_boot/jb_overlay/bin/brick_monitor
ORIGINAL=/mnt/ubi_boot/jb_overlay/bin/brick_monitor.autoABC_real_v1
BB=/mnt/ubi_boot/jb_overlay/bin/busybox
[ -x "$BB" ] || BB=/bin/busybox
OK=YES
bad(){ echo "FAIL $*"; OK=NO; }
info(){ echo "OK $*"; }
hash(){ "$BB" sha256sum "$1" 2>/dev/null | "$BB" awk '{print $1}'; }
proc_has(){
    P="$1"; NAME="$2"
    case "$P" in ''|*[!0-9]*) return 1;; esac
    [ -r "/proc/$P/cmdline" ] || return 1
    CMD="$(tr '\000' ' ' < "/proc/$P/cmdline" 2>/dev/null)"
    case "$CMD" in *"$BASE/$NAME"*) return 0;; esac
    return 1
}
[ -x "$BB" ] || { echo 'FAIL BusyBox missing'; exit 1; }
echo 'autoABC read-only check'
[ -f "$BASE/SHA256SUMS" ] || { bad 'Payload manifest missing'; exit 1; }
[ "$(hash "$BASE/SHA256SUMS")" = "bdf2606dcfa93eefd181f0cc7a2310322352825f95f33980c970cadcd9873d7b" ] && info 'Manifest identity matches this release' || bad 'Manifest identity differs from this release'
COUNT=0
while read SUM FILE; do
    [ -n "$SUM" ] || continue
    COUNT=$((COUNT+1))
    [ -f "$BASE/$FILE" ] || { bad "Missing: $FILE"; continue; }
    [ "$(hash "$BASE/$FILE")" = "$SUM" ] || bad "Hash mismatch: $FILE"
done < "$BASE/SHA256SUMS"
[ "$COUNT" -eq 44 ] && info "Manifest entries: $COUNT" || bad "Unexpected entry count: $COUNT"
[ -f "$BASE/config.ini" ] && "$BASE/config.sh" check "$BASE/config.ini" >/dev/null 2>&1 && info 'Configuration valid' || bad 'Configuration missing or invalid'
ISO="$("$BASE/config.sh" get-iso "$BASE/config.ini" 2>/dev/null)"
case "$ISO" in 0|1) echo "ISO_BDMV=$ISO";; *) bad 'Unrecognized ISO_BDMV value'; ISO=0;; esac
ACTIVE="$(cat /tmp/autoabc_active_iso 2>/dev/null)"
[ "$ISO" = "$ACTIVE" ] && info 'Runtime mode matches config' || bad 'Full power cycle required (or runtime not started)'
[ -f "$TARGET" ] && grep -Fq '# AUTOABC_EARLYBOOT_V1' "$TARGET" 2>/dev/null && info 'Earlyboot wrapper installed' || bad 'Earlyboot wrapper missing'
[ -x "$ORIGINAL" ] && [ -s "$ORIGINAL" ] && info 'Original brick_monitor backup present' || bad 'Original brick_monitor backup missing'
for ITEM in 'regiond:autoabc_disc' 'psr20_hookd:autoabc_psr20'; do
    PF="${ITEM%%:*}"; NAME="${ITEM#*:}"
    P="$(cat "$BASE/$PF.pid" 2>/dev/null)"
    proc_has "$P" "$NAME" && info "$NAME running" || bad "$NAME not running"
done
if [ "$ISO" = 0 ]; then
    P="$(cat "$BASE/virtual_off_pass.pid" 2>/dev/null)"
    proc_has "$P" autoabc_virtual_off_pass && info 'Virtual pass-through guard running' || bad 'Virtual pass-through guard missing'
    [ ! -L /tmp/ra ] && info 'Virtual preplay link disabled' || bad 'Virtual preplay link unexpectedly active'
    for NAME in autoabc_virtual_hook autoabc_virtual_restore autoabc_folder folderd_launcher.sh; do
        for P in /proc/[0-9]*; do
            [ -r "$P/cmdline" ] || continue
            C="$(tr '\000' ' ' < "$P/cmdline" 2>/dev/null)"
            case "$C" in *"$BASE/$NAME"*) bad "Unexpected virtual daemon: $NAME (${P##*/})";; esac
        done
    done
else
    for ITEM in 'hookd:autoabc_virtual_hook' 'restore:autoabc_virtual_restore' 'folderd:autoabc_folder'; do
        PF="${ITEM%%:*}"; NAME="${ITEM#*:}"
        P="$(cat "$BASE/$PF.pid" 2>/dev/null)"
        if proc_has "$P" "$NAME" || { [ "$PF" = folderd ] && proc_has "$P" folderd_launcher.sh; }; then
            info "$NAME running"
        else
            bad "$NAME not running"
        fi
    done
    [ -L /tmp/ra ] && info 'Virtual preplay link enabled' || bad 'Virtual preplay link missing'
    P="$(cat "$BASE/virtual_off_pass.pid" 2>/dev/null)"
    proc_has "$P" autoabc_virtual_off_pass && bad 'Pass-through guard unexpectedly running in ISO_BDMV=1' || :
fi
[ ! -e "$BASE/cache" ] && [ ! -e "$BASE/cache.sh" ] && info 'No legacy cache files' || bad 'Unexpected legacy cache files'
if [ "$OK" = YES ]; then echo 'READONLY_CHECK=PASS'; exit 0; fi
echo 'READONLY_CHECK=FAIL'; exit 1
