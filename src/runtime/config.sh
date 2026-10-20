#!/bin/sh
# Strict single-setting parser, BusyBox awk only. Never source/eval user config.
BASE="/mnt/ubi_boot/autoABC"
BB="/mnt/ubi_boot/jb_overlay/bin/busybox"
[ -x "$BB" ] || BB="/bin/busybox"
MODE="${1:-get-iso}"
FILE="${2:-$BASE/config.ini}"
case "$MODE" in values|get-iso|show|check) ;; *) echo 'USAGE: config.sh [get-iso|values|show|check] [config-file]' >&2; exit 2;; esac
[ -f "$FILE" ] || {
    case "$MODE" in
        values|get-iso) echo 1;;
        show) echo 'ISO_BDMV=1'; echo 'CONFIG_FILE=MISSING_DEFAULT_1';;
        check) echo 'CONFIG=MISSING'; exit 2;;
    esac
    exit 0
}
"$BB" awk -v mode="$MODE" '
BEGIN {iso="1"; n=0; bad=0}
{
    sub(/\r$/, "", $0)
    if ($0 ~ /^[[:space:]]*($|#)/) next
    if ($0 !~ /^[[:space:]]*ISO_BDMV[[:space:]]*=[[:space:]]*[01][[:space:]]*$/) {bad=1; next}
    split($0,p,"=")
    iso=p[2]; gsub(/[[:space:]]/,"",iso)
    n++
}
END {
    if (bad || n!=1) {
        print "CONFIG_INVALID: exactly one ISO_BDMV=0/1, no other settings" > "/dev/stderr"
        exit 2
    }
    if (mode=="values" || mode=="get-iso") print iso
    else if (mode=="show") {print "ISO_BDMV=" iso; print "CONFIG_FILE=VALID"}
    else if (mode=="check") print "CONFIG=VALID"
}
' "$FILE"
