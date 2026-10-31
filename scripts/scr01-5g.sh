#!/usr/bin/env bash
# scr01-5g.sh - report and, where the OS allows, nudge the SCR01 toward 5G for
# Philippine networks. Honest about the hard limits: band locking on this
# MediaTek + unrooted + SELinux-enforcing device is NOT doable from adb.
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$HERE/lib/common.sh"
require_adb

say "Current radio state"
MODE="$("$ADB" shell settings get global preferred_network_mode | tr -d '\r')"
printf '    preferred_network_mode : %s\n' "$MODE"
"$ADB" shell "dumpsys telephony.registry" 2>/dev/null \
  | grep -om1 'getRilDataRadioTechnology=[0-9]*([A-Za-z]*)' | sed 's/^/    /' || true
"$ADB" shell "dumpsys telephony.registry" 2>/dev/null \
  | grep -om1 '5gStatus=[0-9]*' | sed 's/^/    /' || true

say "Hardware 5G bands (fixed in the modem): n28, n41, n77, n78"
say "PH 5G overlap: Smart/Globe n78 (3.5 GHz) and n41 (2.5 GHz) are supported."

say "Applying the widest NR-inclusive mode (26) that adb can set..."
for k in preferred_network_mode preferred_network_mode1 preferred_network_mode2; do
  "$ADB" shell "settings put global $k 26" >/dev/null 2>&1 || true
done
NEW="$("$ADB" shell settings get global preferred_network_mode | tr -d '\r')"
case "$NEW" in
  2[2-9]|3[0-3]) ok "NR is enabled in the preferred mode ($NEW).";;
  *) warn "Mode is $NEW; the OS re-derived it. Use the on-screen steps below.";;
esac

cat <<'TXT'

--------------------------------------------------------------------
To ENABLE 5G for a non-Japanese (PH) carrier and LOCK bands, you must
use the on-device ServiceMode menu. This cannot be scripted over adb
on this device (SECRET_CODE broadcasts are blocked for shell, no root,
SELinux enforcing). Verified on this unit.

On the SCR01 touchscreen:
  1. Open the status/number screen and tap the phone number 10 times
     to unlock the hidden dial code, then open ServiceMode.
  2. NR settings: turn the band allow-list OFF, set SA/NSA mode ON.
  3. (optional) Band selection: keep only n78 (and n41) for the PH.
  4. Reboot the device.

Note: "lock to 5G-only" will drop you to NO service wherever only LTE
is available. For a hotspot, NR/LTE (mode 26) is the reliable choice.
--------------------------------------------------------------------
TXT
