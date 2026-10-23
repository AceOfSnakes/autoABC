#!/bin/sh
BASE="/mnt/ubi_boot/autoABC"; BB="/mnt/ubi_boot/autoABC/bin/busybox"
proc_has(){ P="$1"; shift; case "$P" in ''|*[!0-9]*) return 1;; esac; [ -r "/proc/$P/cmdline" ] || return 1; CMD="$(tr '\000' ' ' < "/proc/$P/cmdline" 2>/dev/null)"; for S in "$@"; do case "$CMD" in *"$S"*) return 0;; esac; done; return 1; }
echo "autoABC status"
if [ -f "$BASE/uopfree_status.sh" ] && [ ! -L "$BASE/uopfree_status.sh" ]; then
    sh "$BASE/uopfree_status.sh" 2>&1 || :
else
    echo 'UOPFREE_STATE=STATUS_SCRIPT_MISSING'
fi

# Embedded read-only hook status helpers: no separate runtime scripts.
hook_status() {
(
set -- $(cat /tmp/autoabc_hook.state 2>/dev/null); P="$1"; PROF="$2"
case "$P" in ''|*[!0-9]*) echo "HOOK=NO_ACTIVE_TARGET"; exit 1;; esac
[ "$(cat /proc/$P/comm 2>/dev/null)" = "bdpprog.1" ] || { echo "HOOK=NO_ACTIVE_TARGET"; exit 1; }
case "$PROF" in base) C=$((0x01c03a00)); W="$BASE/hook/got_wrapper_base.bin";; extended) C=$((0x01c11200)); W="$BASE/hook/got_wrapper_extended.bin";; *) echo "HOOK=UNKNOWN_PROFILE"; exit 1;; esac
T="/tmp/ra_hs.$$"; "$BB" dd if="/proc/$P/mem" of="$T" bs=1 skip=$((0x011d8e40)) count=4 2>/dev/null
if "$BB" cmp -s "$T" "$W"; then
  GOT="$("$BB" hexdump -v -e '1/4 "%08x"' "$T" 2>/dev/null)"; rm -f "$T"
  O="/tmp/ra_ho.$$"; "$BB" dd if="/proc/$P/mem" of="$O" bs=1 skip=$((C+0x20)) count=4 2>/dev/null
  ORIG="$("$BB" hexdump -v -e '1/4 "%08x"' "$O" 2>/dev/null)"; rm -f "$O"
  echo "HOOK=INSTALLED PROFILE=$PROF MODE=GOT_PREPLAY_NO_SIGSTOP_REAL_BDMV_LR_ISO_STRING GOT=0x011d8e40 WRAPPER=0x${GOT:-UNKNOWN} ORIGINAL_IPCD=0x${ORIG:-UNKNOWN}"
else rm -f "$T"; echo "HOOK=NOT_INSTALLED_OR_MISMATCH PROFILE=$PROF"; fi
)
}
psr20_status() {
(
set -- $(cat /tmp/autoabc_psr20_hook.state 2>/dev/null); P="$1"; PROF="$2"
case "$P" in ''|*[!0-9]*) echo "PSR20_GATE=NO_ACTIVE_TARGET"; exit 1;; esac
[ "$(cat /proc/$P/comm 2>/dev/null)" = "bdpprog.1" ] || { echo "PSR20_GATE=NO_ACTIVE_TARGET"; exit 1; }
case "$PROF" in base) C=$((0x01c03c00)); PATCH="$BASE/hook/patch_ngetpsr_base.bin";; extended) C=$((0x01c11400)); PATCH="$BASE/hook/patch_ngetpsr_extended.bin";; *) echo "PSR20_GATE=BAD_PROFILE"; exit 1;; esac
rd4(){ "$BB" dd if="/proc/$P/mem" bs=1 skip="$1" count=4 2>/dev/null | "$BB" hexdump -v -e '1/4 "%08x"'; }
T=/tmp/ra_psr_status.$$; "$BB" dd if="/proc/$P/mem" of="$T" bs=1 skip=$((0x002aefc0)) count=4 2>/dev/null
if "$BB" cmp -s "$T" "$PATCH"; then INST=YES; else INST=NO; fi; rm -f "$T"
MB="$(rd4 $((C+0x0fc)))"; CALLS="$(rd4 $((C+0x100)))"; OVR="$(rd4 $((C+0x104)))"; TO="$(rd4 $((C+0x108)))"
echo "PSR20_GATE=INSTALLED_$INST PID=$P PROFILE=$PROF ENTRY=0x002aefc0 CAVE=$(printf '0x%08x' "$C")"
echo "MAILBOX=0x${MB:-00000000} CALLS_HEX=0x${CALLS:-00000000} OVERRIDES_HEX=0x${OVR:-00000000} TIMEOUTS_HEX=0x${TO:-00000000}"
echo "MAILBOX_VALUES: 00000000=IDLE 80000000=REQUEST 00000001=A 00000002=B 00000004=C ffffffff=PASS"
echo "--- PSR20_HOOKD_LOG_TAIL ---"; "$BB" tail -n 12 "$BASE/psr20_hookd.log" 2>/dev/null
echo "--- DISC_DETECTOR_LOG_TAIL ---"; "$BB" tail -n 16 "$BASE/regiond.log" 2>/dev/null
)
}

echo '--- CONFIGURATION ---'
"$BASE/config.sh" show 2>&1 || echo 'CONFIG=INVALID_SAFE_DEFAULT_0'
DESIRED="$("$BASE/config.sh" get-iso 2>/dev/null)" || DESIRED=0
ACTIVE_CONFIG=/tmp/autoabc_active_iso
if [ -f "$ACTIVE_CONFIG" ]; then
    ACTIVE="$(cat "$ACTIVE_CONFIG" 2>/dev/null)"
    echo "RUNTIME_ISO_BDMV=$ACTIVE"
    if [ "$ACTIVE" = "$DESIRED" ]; then echo 'CONFIG_RESTART_REQUIRED=NO'; else echo 'CONFIG_RESTART_REQUIRED=YES'; fi
else
    echo 'RUNTIME_ISO_BDMV=UNKNOWN_NOT_STARTED'
fi
# In ISO_BDMV=0 only the PSR20 PASS guard is expected; no virtual region daemons.
ISOMODE="${ACTIVE:-$DESIRED}"
if [ "$ISOMODE" = 0 ]; then
    P="$(cat "$BASE/virtual_off_pass.pid" 2>/dev/null)"
    if proc_has "$P" "$BASE/autoabc_virtual_off_pass"; then
        echo "VIRTUAL_OFF_PSR20_PASS_GUARD=RUNNING PID=$P"
    else
        echo 'VIRTUAL_OFF_PSR20_PASS_GUARD=NOT_RUNNING'
    fi
fi
for X in "psr20_gate:$BASE/psr20_hookd.pid:$BASE/autoabc_psr20" "hookd:$BASE/hookd.pid:$BASE/autoabc_virtual_hook" "virtual_restore:$BASE/restore.pid:$BASE/autoabc_virtual_restore" "regiond:$BASE/regiond.pid:$BASE/autoabc_disc" "folderd_native:$BASE/folderd.pid:$BASE/autoabc_folder"; do OLDIFS="$IFS"; IFS=:; set -- $X; IFS="$OLDIFS"; P="$(cat "$2" 2>/dev/null)"; if proc_has "$P" "$3"; then echo "$1=RUNNING PID=$P"; else echo "$1=STOPPED"; fi; done
hook_status 2>/dev/null || :
psr20_status 2>/dev/null || :
echo "--- HDMV FALLBACK ---"; [ -x "$BASE/autoabc_hdmv" ] && echo "hdmv_fallback=READY" || echo "hdmv_fallback=MISSING"
echo "--- REGION ---"; "$BASE/autoabcctl" status 2>/dev/null || :
echo "--- psr20_hookd.log ---"; "$BB" tail -n 20 "$BASE/psr20_hookd.log" 2>/dev/null
echo "--- hookd.log ---"; "$BB" tail -n 20 "$BASE/hookd.log" 2>/dev/null
echo "--- virtual.log ---"; "$BB" tail -n 20 "$BASE/virtual.log" 2>/dev/null
echo "--- restore.log ---"; "$BB" tail -n 20 "$BASE/restore.log" 2>/dev/null
echo "--- regiond.log ---"; "$BB" tail -n 30 "$BASE/regiond.log" 2>/dev/null
echo "--- folderd.log ---"; "$BB" tail -n 10 "$BASE/folderd.log" 2>/dev/null

echo "--- PHYSICAL STATE ---"; "$BB" cat "$BASE/regiond.state" 2>/dev/null
