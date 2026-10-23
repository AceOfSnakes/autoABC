#!/bin/sh
# AUTOABC_MKV_EARLY_PREV_110
# An owned, verified predecessor of the UNMODIFIED oppo-dv-mkv v1.5/v1.6
# boot wrapper, used only on MKV-only installs with EARLYBOOT=1.
# Prime autoABC's existing daemons before the player is executed. Bounded
# fail-open: a failed/hung autoABC never prevents the OPPO player from booting.
BASE='/mnt/ubi_boot/autoABC'
PLAYER='/usr/local/bin/bdpprog.1'
BB="$BASE/bin/busybox"
READY="/tmp/autoabc110-mkv-early.$$.ready"
WAITING="/tmp/autoabc110-mkv-early.$$.waiting"
MAX_POLLS=100
log(){ printf 'MKV_EARLYBOOT %s\n' "$*" >> "$BASE/earlyboot.log" 2>/dev/null || :; }
# The one-shot UOPfree worker waits for bdpprog.1 independently in the
# background. It never owns the region hooks and cannot hold the boot chain.
if [ -x "$BASE/uopfree_launch.sh" ]; then
    ( sh "$BASE/uopfree_launch.sh" >> "$BASE/uopfree.log" 2>&1 ) &
fi
physical_ready(){
    for F in regiond.pid psr20_hookd.pid; do
        PID="$(cat "$BASE/$F" 2>/dev/null)"
        case "$PID" in ''|*[!0-9]*) return 1;; esac
        [ -r "/proc/$PID/cmdline" ] && kill -0 "$PID" 2>/dev/null || return 1
        # A reused PID or unrelated process is not evidence of readiness.
        case "$F" in regiond.pid) NAME='autoabc_disc';; *) NAME='autoabc_psr20';; esac
        CMD="$(tr '\000' ' ' < "/proc/$PID/cmdline" 2>/dev/null)"
        case "$CMD" in *"$BASE/$NAME"*) ;; *) return 1;; esac
    done
    return 0
}
if [ -x "$BASE/start.sh" ] && [ -x "$BB" ]; then
    umask 077
    rm -f "$READY" "$WAITING" 2>/dev/null || :
    if : > "$WAITING"; then
        # Run the SAME Region Core as EARLYBOOT=0; no region algorithms altered.
        ( sh "$BASE/start.sh" >> "$BASE/boot.log" 2>&1
          RC=$?
          [ -f "$WAITING" ] && printf '%s\n' "$RC" > "$READY"
        ) >/dev/null 2>&1 &
        N=0
        STATUS='TIMEOUT'
        while [ "$N" -lt "$MAX_POLLS" ]; do
            if [ -f "$READY" ]; then
                case "$(cat "$READY" 2>/dev/null)" in
                    0) if physical_ready; then STATUS='DAEMONS_STARTED'; break; fi ;;
                    *) STATUS='CORE_START_FAILED'; break ;;
                esac
            fi
            # Never allow a broken/missing usleep applet to turn the three-
            # second watchdog into an unbounded boot delay.
            if ! "$BB" usleep 30000 2>/dev/null; then
                STATUS='WAIT_TIMER_UNAVAILABLE'
                break
            fi
            N=$((N+1))
        done
        rm -f "$WAITING" "$READY" 2>/dev/null || :
        log "$STATUS polls=$N (player always started)"
    else
        log 'UNABLE_TO_CREATE_BOUNDED_WAIT_MARKER (player always started)'
    fi
else
    log 'CORE_OR_BUSYBOX_MISSING (player always started)'
fi
exec "$PLAYER" "$@"
