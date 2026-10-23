#!/bin/sh
BASE="/mnt/ubi_boot/autoABC"; BB="/mnt/ubi_boot/autoABC/bin/busybox"
# Cooperative UOPfree shutdown. Never SIGKILL a worker that may write RAM.
# Do this BEFORE stopping Region Core, so an unresponsive UOPfree keeps the
# existing installation intact and the uninstaller can safely abort.
if [ -d "$BASE" ] && [ ! -L "$BASE" ]; then
    : > "$BASE/uopfree.cancel" || { echo 'UOPFREE_CANCEL_FAILED'; exit 1; }
fi
uop_present(){
    for Q in /proc/[0-9]*; do
        [ -r "$Q/cmdline" ] || continue
        CMD="$(tr '\000' ' ' < "$Q/cmdline" 2>/dev/null)"
        case "$CMD" in *"$BASE/uopfree.sh"*) return 0;; esac
    done
    return 1
}
N=0
while uop_present; do
    if [ "$N" -ge 80 ]; then rm -f "$BASE/uopfree.cancel" 2>/dev/null || :; echo 'UOPFREE_WORKER_STILL_ACTIVE_SAFE_ABORT'; exit 1; fi
    "$BB" usleep 100000 2>/dev/null || { rm -f "$BASE/uopfree.cancel" 2>/dev/null || :; echo 'UOPFREE_WAIT_TIMER_UNAVAILABLE_SAFE_ABORT'; exit 1; }
    N=$((N+1))
done
# Stale ownership marker may persist after an interrupted process; no longer
# running is the only prerequisite for a safe Region Core shutdown.
rm -f "$BASE/uopfree.pid" 2>/dev/null || :
touch /tmp/autoabc_disabled
proc_has(){ P="$1"; shift; case "$P" in ''|*[!0-9]*) return 1;; esac; [ -r "/proc/$P/cmdline" ] || return 1; CMD="$(tr '\000' ' ' < "/proc/$P/cmdline" 2>/dev/null)"; for S in "$@"; do case "$CMD" in *"$S"*) return 0;; esac; done; return 1; }
stop_one(){ PF="$1"; shift; P="$(cat "$PF" 2>/dev/null)"; if proc_has "$P" "$@"; then kill -TERM "$P" 2>/dev/null; "$BB" usleep 300000 2>/dev/null || :; proc_has "$P" "$@" && kill -KILL "$P" 2>/dev/null; fi; rm -f "$PF"; }
# Stop virtual pass-through before restoring the physical PSR20 hook.
stop_one "$BASE/virtual_off_pass.pid" "$BASE/autoabc_virtual_off_pass"
# Restore both runtime hooks before stopping the detector daemons.
stop_one "$BASE/psr20_hookd.pid" "$BASE/autoabc_psr20"
stop_one "$BASE/hookd.pid" "$BASE/autoabc_virtual_hook"
stop_one "$BASE/restore.pid" "$BASE/autoabc_virtual_restore"
stop_one "$BASE/folderd.pid" "$BASE/folderd_launcher.sh" "$BASE/autoabc_folder"
stop_one "$BASE/regiond.pid" "$BASE/autoabc_disc"
rm -f /tmp/ra /tmp/autoabc_virtual.state /tmp/autoabc_preplay.lock /tmp/autoabc_hook.state /tmp/autoabc_bdpprog.pid /tmp/autoabc_psr20_hook.state
"$BASE/autoabcctl" off >/dev/null 2>&1
: > "$BASE/regiond.state" 2>/dev/null || :
echo "autoABC stopped; hook cleanup requested and region reset attempted"
