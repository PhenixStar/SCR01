#!/usr/bin/env bash
# scr01-apn.sh - guided APN setup for Philippine carriers. Writing APNs over
# adb is denied on this device (telephony provider needs WRITE_APN_SETTINGS,
# which the shell lacks - verified). So this opens the APN screen via adb and
# prints the values to enter. Values are community-documented defaults (no
# official 2026 source found); confirm with your carrier. The SCR01 is a
# hotspot/dongle, so the dongle-style APN is listed first where it differs.
#   scr01 apn [smart|globe|dito]   guided value entry (default)
#   scr01 apn --verify             check mobile data works after you entered it
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$HERE/lib/common.sh"
require_adb

# --- connectivity verification ----------------------------------------------
# After APNs are typed on-device, confirm data actually works. Shell-user ping
# is normally permitted (unlike the APN provider write). Reports the real result.
if [ "${1:-}" = "--verify" ] || [ "${1:-}" = "-v" ]; then
  say "Verifying mobile data connectivity over the device's radio..."
  radio="$("$ADB" shell getprop gsm.network.type 2>/dev/null | tr -d '\r')"
  [ -n "$radio" ] && say "Radio reports network type: $radio"
  # ping exits non-zero when unreachable (the case we are diagnosing); keep its
  # output and swallow the status so set -e/pipefail do not abort before we warn.
  out="$("$ADB" shell 'ping -c 3 -W 3 8.8.8.8' 2>&1 | tr -d '\r')" || true
  echo "$out"
  if printf '%s' "$out" | grep -qE '[1-3] (packets )?received|, 0% packet loss'; then
    ok "Data path is up (ICMP reached 8.8.8.8). APN is working."
    log_run apn verify-ok "type=${radio:-?}"
  else
    warn "No reply. Check: APN selected, mobile data toggled on, SIM has data, signal present."
    warn "(If ping itself is blocked on this image, open a site in the device browser to confirm.)"
    log_run apn verify-fail "type=${radio:-?}"
  fi
  exit 0
fi

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
say "After saving, select the new APN and toggle mobile data off/on, then: scr01 apn --verify"
log_run apn guided "${1:-all}"
