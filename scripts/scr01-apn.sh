#!/usr/bin/env bash
# scr01-apn.sh - guided APN setup for Philippine carriers. Writing APNs over
# adb is denied on this device (telephony provider needs WRITE_APN_SETTINGS,
# which the shell lacks - verified). So this opens the APN screen via adb and
# prints the values to enter. Values are community-documented defaults (no
# official 2026 source found); confirm with your carrier. The SCR01 is a
# hotspot/dongle, so the dongle-style APN is listed first where it differs.
# Usage: scr01 apn [smart|globe|dito]
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$HERE/lib/common.sh"
require_adb

print_smart() { cat <<'T'
  Carrier: Smart / TNT / Sun
    Name     : Smart Internet
    APN      : internet                  (pocket-wifi/dongle; this device)
    APN (alt): internet.smart.com.ph     (phone profile, if the above fails)
    User/Pass: (leave blank)
    APN type : default,supl
T
}
print_globe() { cat <<'T'
  Carrier: Globe / TM
    Name     : Globe Internet
    APN      : internet.globe.com.ph     (postpaid)
    APN (alt): http.globe.com.ph         (prepaid)
    User/Pass: (leave blank)
    APN type : default,supl
T
}
print_dito() { cat <<'T'
  Carrier: DITO
    Name     : DITO Internet
    APN      : internet.dito.ph
    APN (alt): dito
    User/Pass: (leave blank)
    APN type : default,supl
T
}

say "APN values cannot be written over adb on this device (no WRITE_APN_SETTINGS)."
say "Opening the APN settings screen on the device..."
"$ADB" shell "am start -a android.settings.APN_SETTINGS" >/dev/null 2>&1 \
  && ok "APN settings opened. Tap + (Add) and enter:" \
  || warn "Could not open APN screen; open Settings > Connections > Mobile networks > APN manually."

echo
case "${1:-}" in
  smart) print_smart;;
  globe) print_globe;;
  dito)  print_dito;;
  *) say "Pass a carrier: smart | globe | dito. All shown below:"; echo
     print_smart; echo; print_globe; echo; print_dito;;
esac
echo
warn "These are community-documented values, not an official 2026 source. Confirm with your carrier."
say "After saving, select the new APN and toggle mobile data off/on."
log_run apn guided "${1:-all}"
