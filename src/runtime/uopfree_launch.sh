#!/bin/sh
# Independent, non-blocking UOPfree launch target for autoABC boot adapters.
# Caller MUST run this in background; nothing here controls region services.
BASE='/mnt/ubi_boot/autoABC'
CONF="$BASE/uopfree.ini"
[ -f "$CONF" ] && [ ! -L "$CONF" ] || { echo 'UOPfree CONFIG_MISSING'; exit 0; }
case "$(cat "$CONF" 2>/dev/null)" in
    'UOPFREE=0') echo 'UOPfree DISABLED'; exit 0 ;;
    'UOPFREE=1') ;;
    *) echo 'UOPfree CONFIG_INVALID - SKIPPED'; exit 0 ;;
esac
# Never compete with a separate UOPfree install (including after install).
if [ -e /mnt/ubi_boot/UOPfree ] || [ -L /mnt/ubi_boot/UOPfree ] || [ -e /mnt/ubi_boot/bluray_uop ] || [ -L /mnt/ubi_boot/bluray_uop ]; then
    echo 'UOPfree STANDALONE_DETECTED - SKIPPED'
    exit 0
fi
[ -f "$BASE/uopfree.sh" ] && [ ! -L "$BASE/uopfree.sh" ] || { echo 'UOPfree MODULE_MISSING'; exit 0; }
exec sh "$BASE/uopfree.sh"
