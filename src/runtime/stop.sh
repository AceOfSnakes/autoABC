#!/bin/sh
BASE="/mnt/ubi_boot/autoABC"; BB="/mnt/ubi_boot/jb_overlay/bin/busybox"; [ -x "$BB" ] || BB="/bin/busybox"
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
