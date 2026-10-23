#!/bin/sh
VERSION="autoABC"
BASE="/mnt/ubi_boot/autoABC"; BB="/mnt/ubi_boot/autoABC/bin/busybox"
ISO_BDMV="$("$BASE/config.sh" get-iso 2>/dev/null)" || { echo 'CONFIG_INVALID: using safe ISO_BDMV=0'; ISO_BDMV=0; }
case "$ISO_BDMV" in 0|1) ;; *) echo 'CONFIG_UNKNOWN: using safe ISO_BDMV=0'; ISO_BDMV=0;; esac
ACTIVE_CONFIG=/tmp/autoabc_active_iso
# If configuration changes in an active session, do not tear down the hooks.
if [ -f "$ACTIVE_CONFIG" ] && [ "$(cat "$ACTIVE_CONFIG" 2>/dev/null)" != "$ISO_BDMV" ]; then
    echo "AUTOABC_CONFIG_CHANGED: POWER_CYCLE_REQUIRED (running=$(cat "$ACTIVE_CONFIG") requested=$ISO_BDMV)"
    exit 0
fi
chmod 755 "$BASE"/* "$BASE"/hook/* 2>/dev/null
rm -f /tmp/autoabc_disabled
if [ "$ISO_BDMV" = 1 ]; then
    ln -sf "$BASE/preplay_virtual.sh" /tmp/ra
else
    # NO virtual GOT hook, folder daemon or restore daemon in OFF mode.
    rm -f /tmp/ra /tmp/autoabc_virtual.state /tmp/autoabc_preplay.lock
fi
proc_has(){ P="$1"; shift; case "$P" in ''|*[!0-9]*) return 1;; esac; [ -r "/proc/$P/cmdline" ] || return 1; CMD="$(tr '\000' ' ' < "/proc/$P/cmdline" 2>/dev/null)"; for S in "$@"; do case "$CMD" in *"$S"*) return 0;; esac; done; return 1; }
all_running(){
    P="$(cat "$BASE/regiond.pid" 2>/dev/null)"; proc_has "$P" "$BASE/autoabc_disc" || return 1
    P="$(cat "$BASE/psr20_hookd.pid" 2>/dev/null)"; proc_has "$P" "$BASE/autoabc_psr20" || return 1
    if [ "$ISO_BDMV" = 1 ]; then
        P="$(cat "$BASE/hookd.pid" 2>/dev/null)"; proc_has "$P" "$BASE/autoabc_virtual_hook" || return 1
        P="$(cat "$BASE/restore.pid" 2>/dev/null)"; proc_has "$P" "$BASE/autoabc_virtual_restore" || return 1
        P="$(cat "$BASE/folderd.pid" 2>/dev/null)"; proc_has "$P" "$BASE/folderd_launcher.sh" "$BASE/autoabc_folder" || return 1
    else
        # Fail closed if a stale virtual daemon remains active.
        P="$(cat "$BASE/virtual_off_pass.pid" 2>/dev/null)"
        proc_has "$P" "$BASE/autoabc_virtual_off_pass" || return 1
        for P in /proc/[0-9]*; do
            [ -r "$P/cmdline" ] || continue
            C="$(tr '\000' ' ' < "$P/cmdline" 2>/dev/null)"
            case "$C" in *"$BASE/autoabc_virtual_hook"*|*"$BASE/autoabc_virtual_restore"*|*"$BASE/autoabc_folder"*|*"$BASE/folderd_launcher.sh"*) return 1;; esac
        done
    fi
    return 0
}
# The early-boot wrapper may be followed by a second autostart invocation.
# Never tear down a healthy session during this
# second call.
if all_running; then
    echo "$VERSION already running"
    exit 0
fi
old_present(){
    for p in /proc/[0-9]*; do
        [ -r "$p/cmdline" ] || continue
        C="$(tr '\000' ' ' < "$p/cmdline" 2>/dev/null)"
        case "$C" in
            *"/mnt/ubi_boot/autoABC/autoabc_psr20"*|*"/mnt/ubi_boot/autoABC/autoabc_virtual_hook"*|*"/mnt/ubi_boot/autoABC/autoabc_virtual_restore"*|*"/mnt/ubi_boot/autoABC/autoabc_disc"*|*"/mnt/ubi_boot/autoABC/folderd_launcher.sh"*|*"/mnt/ubi_boot/autoABC/autoabc_folder"*|*"/mnt/ubi_boot/autoABC/autoabc_virtual_off_pass"*) return 0;;
        esac
    done
    return 1
}
kill_old(){ SIG="$1"; for p in /proc/[0-9]*; do [ -r "$p/cmdline" ] || continue; C="$(tr '\000' ' ' < "$p/cmdline" 2>/dev/null)"; case "$C" in *"/mnt/ubi_boot/autoABC/autoabc_psr20"*|*"/mnt/ubi_boot/autoABC/autoabc_virtual_hook"*|*"/mnt/ubi_boot/autoABC/autoabc_virtual_restore"*|*"/mnt/ubi_boot/autoABC/autoabc_disc"*|*"/mnt/ubi_boot/autoABC/folderd_launcher.sh"*|*"/mnt/ubi_boot/autoABC/autoabc_folder"*|*"/mnt/ubi_boot/autoABC/autoabc_virtual_off_pass"*) kill -"$SIG" "${p##*/}" 2>/dev/null;; esac; done; }
# On a clean boot there is nothing to retire, so avoid the old unconditional
# 250 ms wait. The wait is retained only when stale RegionAuto daemons exist.
if old_present; then
    kill_old TERM
    "$BB" usleep 250000 2>/dev/null || :
    kill_old KILL
fi
rm -f "$BASE"/*.pid /tmp/autoabc_virtual.state /tmp/autoabc_preplay.lock /tmp/autoabc_hook.state /tmp/autoabc_bdpprog.pid /tmp/autoabc_psr20_hook.state
start_script(){ NAME="$1"; PF="$2"; LOG="$3"; shift 3; "$BASE/$NAME" >>"$LOG" 2>&1 & LP=$!; "$BB" usleep 30000 2>/dev/null || :; P="$(cat "$PF" 2>/dev/null)"; if proc_has "$P" "$@"; then echo "$NAME=STARTED PID=$P"; return 0; fi; if proc_has "$LP" "$@"; then echo "$LP" > "$PF"; echo "$NAME=STARTED PID=$LP"; return 0; fi; echo "$NAME=STARTING PID=$LP"; }
# Physical region detection and HBI-controlled BD-J playback hold.
# Independent of ISO_BDMV; all physical disc paths always remain active.
start_script autoabc_disc "$BASE/regiond.pid" "$BASE/regiond.log" "$BASE/autoabc_disc"
# Install the narrow physical-only Java RegisterAccess.getPSR(20) gate before
# normal playback can reach BD-J region code. It never patches PERS itself.
start_script autoabc_psr20 "$BASE/psr20_hookd.pid" "$BASE/psr20_hookd.log" "$BASE/autoabc_psr20"
# Virtual region control is optional; the default is enabled.
if [ "$ISO_BDMV" = 1 ]; then
    start_script autoabc_virtual_hook "$BASE/hookd.pid" "$BASE/hookd.log" "$BASE/autoabc_virtual_hook"
    start_script autoabc_virtual_restore "$BASE/restore.pid" "$BASE/restore.log" "$BASE/autoabc_virtual_restore"
    start_script folderd_launcher.sh "$BASE/folderd.pid" "$BASE/folderd.log" "$BASE/folderd_launcher.sh" "$BASE/autoabc_folder"
else
    start_script autoabc_virtual_off_pass "$BASE/virtual_off_pass.pid" "$BASE/virtual_off_pass.log" "$BASE/autoabc_virtual_off_pass"
    echo 'ISO_BDMV=0 VIRTUAL_REGION_DAEMONS=DISABLED PASS_GUARD=ENABLED'
fi
printf '%s\n' "$ISO_BDMV" > "$ACTIVE_CONFIG"
echo "$VERSION started ISO_BDMV=$ISO_BDMV"
