#!/bin/sh
# autoABC 1.1.0; strictly parse both settings, never eval/source config.
BASE="/mnt/ubi_boot/autoABC"
BB="${AUTOABC_BOOTSTRAP_BB:-$BASE/bin/busybox}"
[ -x "$BB" ] || { echo 'BUSYBOX_MISSING' >&2; exit 2; }
MODE="${1:-get-iso}"
FILE="${2:-$BASE/config.ini}"
case "$MODE" in get-iso|get-earlyboot|values|show|check) ;; *) echo 'USAGE: config.sh [get-iso|get-earlyboot|show|check] [config-file]' >&2; exit 2;; esac
[ -f "$FILE" ] || { echo 'CONFIG_MISSING' >&2; exit 2; }
"$BB" awk -v mode="$MODE" '
BEGIN {iso=""; early=""; bad=0; ni=0; ne=0}
{
    if (NR == 1) sub(/^\357\273\277/, "", $0)
    sub(/\r$/, "", $0)
    if ($0 ~ /^[[:space:]]*($|#)/) next
    if ($0 ~ /^[[:space:]]*ISO_BDMV[[:space:]]*=[[:space:]]*[01][[:space:]]*$/) {
        split($0,a,"="); iso=a[2]; gsub(/[[:space:]]/,"",iso); ni++; next
    }
    if ($0 ~ /^[[:space:]]*EARLYBOOT[[:space:]]*=[[:space:]]*[01][[:space:]]*$/) {
        split($0,a,"="); early=a[2]; gsub(/[[:space:]]/,"",early); ne++; next
    }
    bad=1
}
END {
    if (bad || ni!=1 || ne!=1) {
        print "CONFIG_INVALID: exactly one ISO_BDMV=0/1 and EARLYBOOT=0/1" > "/dev/stderr"; exit 2
    }
    if (mode=="get-iso" || mode=="values") print iso
    if (mode=="get-earlyboot") print early
    if (mode=="show") {print "ISO_BDMV=" iso; print "EARLYBOOT=" early; print "CONFIG=VALID"}
    if (mode=="check") print "CONFIG=VALID"
}
' "$FILE"
