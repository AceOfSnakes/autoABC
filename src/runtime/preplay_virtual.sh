#!/bin/sh
VERSION="autoABC virtual preplay"
BASE="/mnt/ubi_boot/autoABC"
FAST="$BASE/autoabc_detect"
HF="$BASE/autoabc_hdmv"
CG="$BASE/autoabc_bdj"
LOG="$BASE/virtual.log"
STATE="/tmp/autoabc_virtual.state"
SEQFILE="/tmp/autoabc_virtual.seq"
LOCK="/tmp/autoabc_preplay.lock"
DISABLED="/tmp/autoabc_disabled"
BB="/mnt/ubi_boot/autoABC/bin/busybox"
TYPE="$1"
case "$TYPE" in b) TYPE=bdmv;; i) TYPE=iso;; esac
# Defense-in-depth: virtual region selection is never allowed in OFF mode.
[ "$("$BASE/config.sh" get-iso 2>/dev/null)" = 1 ] || exit 0

[ -e "$DISABLED" ] && exit 0
mkdir "$LOCK" 2>/dev/null || { echo "PREPLAY_REENTRY_SKIP type=$TYPE" >> "$LOG"; exit 0; }
cleanup(){ rmdir "$LOCK" 2>/dev/null || :; }
trap 'cleanup' 0
trap 'exit 0' 1 2 15
log(){ TS="$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null)"; [ -n "$TS" ] || TS=NO_DATE; echo "$TS $*" >> "$LOG"; }
find_pid(){
    set -- $(cat /tmp/autoabc_hook.state 2>/dev/null); P="$1"
    case "$P" in ''|*[!0-9]*) P="";; esac
    if [ -n "$P" ] && [ "$(cat /proc/$P/comm 2>/dev/null)" = "bdpprog.1" ] && [ -r "/proc/$P/mem" ]; then echo "$P"; return 0; fi
    for p in /proc/[0-9]*; do [ -r "$p/comm" ] || continue; [ "$(cat "$p/comm" 2>/dev/null)" = "bdpprog.1" ] && { echo "${p##*/}"; return 0; }; done
    return 1
}
set_region(){ case "$1" in A) "$FAST" set "$PID" A >/dev/null 2>&1;; B) "$FAST" set "$PID" B >/dev/null 2>&1;; C) "$FAST" set "$PID" C >/dev/null 2>&1;; FREE) "$FAST" set "$PID" off >/dev/null 2>&1;; esac; }
mask_region(){ case "$1" in 1) echo A;; 2) echo B;; 3) echo A;; 4) echo C;; 5) echo A;; 6) echo B;; 7) echo FREE;; *) echo UNKNOWN;; esac; }
core_region(){ case "$1" in A|1) echo A;; B|2) echo B;; A+B|3) echo A;; C|4) echo C;; A+C|5) echo A;; B+C|6) echo B;; A+B+C|7|FREE) echo FREE;; *) echo UNKNOWN;; esac; }
PID="$(find_pid)"; [ -n "$PID" ] || { log "PREPLAY_SKIP no_bdpprog type=$TYPE"; exit 0; }
case "$TYPE" in
 bdmv)
    SRC="$("$BB" readlink /mnt/link 2>/dev/null)"
    [ -n "$SRC" ] && [ -f "$SRC/BDMV/MovieObject.bdmv" ] || { log "PREPLAY_SKIP type=BDMV invalid_link source=${SRC:-NONE}"; exit 0; }
    MOBJ="$SRC/BDMV/MovieObject.bdmv"; LABEL="$SRC" ;;
 iso)
    grep -q '^/dev/loop1 /mnt/iso ' /proc/mounts 2>/dev/null || { log "PREPLAY_SKIP type=ISO loop1_not_mounted"; exit 0; }
    MOBJ="/mnt/iso/BDMV/MovieObject.bdmv"; [ -f "$MOBJ" ] || { log "PREPLAY_SKIP type=ISO no_movieobject"; exit 0; }; LABEL="/mnt/iso" ;;
 *) log "PREPLAY_SKIP bad_type=${TYPE:-NONE}"; exit 0;;
esac

CORE="$("$FAST" detect "$MOBJ" 2>/dev/null)"; [ -n "$CORE" ] || CORE=UNKNOWN
REGION="$(core_region "$CORE")"; DET=CORE; MASK=""; HREGION=""; VALIDATION=""

# Use the native-HDMV validator for virtual ISO/BDMV sources.
# A concrete A/B/C CORE answer is
# kept unless the HDMV control-flow parser itself produces a conflicting A/B/C
# answer. FREE remains owned by CORE. UNKNOWN/AMBIGUOUS tries HDMV first, then
# falls through to the BD-J callgraph path.
case "$REGION" in
 A|B|C)
    if [ -x "$HF" ]; then
        HREGION="$("$HF" "$MOBJ" 2>/dev/null)"
        case "$HREGION" in
            A|B|C)
                if [ "$HREGION" != "$REGION" ]; then
                    VALIDATION="CONFLICT core_region=$REGION hdmv_region=$HREGION action=OVERRIDE"
                    REGION="$HREGION"
                    DET=HDMV_CONTROLFLOW_VALIDATOR
                else
                    VALIDATION="VALIDATED region=$REGION action=KEEP_CORE"
                fi
                ;;
        esac
    fi
    ;;
 UNKNOWN)
    if [ -x "$HF" ]; then
        HREGION="$("$HF" "$MOBJ" 2>/dev/null)"
        case "$HREGION" in
            A|B|C)
                REGION="$HREGION"
                DET=HDMV_CONTROLFLOW_FALLBACK
                ;;
        esac
    fi
    if [ "$REGION" = "UNKNOWN" ]; then
        MASK="$("$CG" "$MOBJ" 2>/dev/null)"
        REGION="$(mask_region "$MASK")"
        DET=CALLGRAPH
    fi
    ;;
esac

# Re-validate the selected virtual source after all parsing and before changing
# CBR, so a mount/link handoff cannot apply a decision to a different source.
case "$TYPE" in
 bdmv) CUR="$("$BB" readlink /mnt/link 2>/dev/null)"; [ "$CUR" = "$SRC" ] || { log "PREPLAY_SOURCE_CHANGED type=BDMV old=$SRC new=${CUR:-NONE}"; exit 0; };;
 iso) grep -q '^/dev/loop1 /mnt/iso ' /proc/mounts 2>/dev/null && [ -f "$MOBJ" ] || { log "PREPLAY_SOURCE_CHANGED type=ISO"; exit 0; };;
esac

[ -n "$VALIDATION" ] && log "PREPLAY_HDMV_CORE_$VALIDATION type=$TYPE source=$LABEL"
case "$REGION" in
 A|B|C)
    set_region "$REGION"
    SEQ="$(cat "$SEQFILE" 2>/dev/null)"; case "$SEQ" in ''|*[!0-9]*) SEQ=0;; esac; SEQ=$((SEQ+1)); echo "$SEQ" > "$SEQFILE"
    TMP="${STATE}.$$"; echo "$SEQ $PID $REGION $TYPE" > "$TMP"; mv -f "$TMP" "$STATE"
    log "PREPLAY_APPLY gen=$SEQ type=$TYPE region=$REGION detector=$DET core=$CORE hdmv=${HREGION:-NA} mask=${MASK:-NA} source=$LABEL" ;;
 FREE) set_region FREE; rm -f "$STATE"; log "PREPLAY_FREE type=$TYPE detector=$DET core=$CORE hdmv=${HREGION:-NA} mask=${MASK:-NA} source=$LABEL" ;;
 *) rm -f "$STATE"; log "PREPLAY_UNKNOWN type=$TYPE core=$CORE detector=$DET hdmv=${HREGION:-NA} mask=${MASK:-NA} source=$LABEL" ;;
esac
exit 0
