#!/usr/bin/env bash
# scr01-apn.sh - guided APN setup for Philippine carriers. Writing APNs over
# adb is denied on this device (telephony provider needs WRITE_APN_SETTINGS,
# which the shell lacks - verified). So this opens the APN screen via adb and
# prints the exact values to enter. Values are the common defaults; confirm
# against your plan. Usage: scr01 apn [smart|globe|dito]
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$HERE/lib/common.sh"
require_adb

carrier="${1:-}"
print_smart() { cat <<'T'
  Carrier: Smart / TNT / Sun (MCC/MNC 515/03)
    Name     : Smart Internet
    APN      : internet
    APN type : default,supl
    Auth/user: (leave blank)
T
}
print_globe() { cat <<'T'
  Carrier: Globe / TM (MCC/MNC 515/02)
    Name     : Globe Internet
    APN      : internet.globe.com.ph
    Username : globe
    Password : globe
    APN type : default,supl
T
}
print_dito() { cat <<'T'
  Carrier: DITO (MCC/MNC 515/66)
    Name     : DITO
    APN      : dito
    APN type : default,supl
    Auth/user: (leave blank)
T
}

say "APN values cannot be written over adb on this device (no WRITE_APN_SETTINGS)."
say "Opening the APN settings screen on the device..."
"$ADB" shell "am start -a android.settings.APN_SETTINGS" >/dev/null 2>&1 \
  && ok "APN settings opened. Tap + (Add) and enter:" \
  || warn "Could not open APN screen; open Settings > Connections > Mobile networks > APN manually."

echo
case "$carrier" in
  smart) print_smart;;
  globe) print_globe;;
  dito)  print_dito;;
  *) say "Common Philippine carriers (pass one: smart | globe | dito):"; echo
     print_smart; echo; print_globe; echo; print_dito;;
esac
echo
say "After saving, select the new APN and toggle mobile data off/on."
log_run apn guided "${carrier:-all}"
