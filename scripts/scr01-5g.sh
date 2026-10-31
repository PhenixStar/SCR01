#!/usr/bin/env bash
# scr01-5g.sh - report and nudge the SCR01 toward 5G for PH networks. With
# --guide, walk the on-device ServiceMode band-lock steps interactively (the
# only route available: shell cannot open ServiceMode on this device).
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$HERE/lib/common.sh"
require_adb

guide() {
  say "On-device ServiceMode band lock (follow on the SCR01 touchscreen)"
  local steps=(
    "Tap the phone number 10 times on the status screen to unlock the dial code, then open ServiceMode."
    "Open NR settings. Turn the band allow-list OFF."
    "Set SA/NSA mode ON."
    "Band selection (optional): keep only n78 and n41 for the Philippines."
    "Reboot the device."
  )
  local i=1
  for s in "${steps[@]}"; do
    printf '\n  Step %d/%d: %s\n' "$i" "${#steps[@]}" "$s"
    read -r -p "    press Enter when done (or q to stop) " a; [ "$a" = q ] && { warn "Stopped at step $i"; log_run 5g-guide partial "stopped@$i"; return; }
    i=$((i+1))
  done
  ok "Guide complete."; log_run 5g-guide ok "walked ${#steps[@]} steps"
}

say "Current radio state"
MODE="$("$ADB" shell settings get global preferred_network_mode | tr -d '\r')"
printf '    preferred_network_mode : %s\n' "$MODE"
"$ADB" shell "dumpsys telephony.registry" 2>/dev/null | grep -om1 '5gStatus=[0-9]*' | sed 's/^/    /' || true

say "Hardware 5G bands (fixed): n28, n41, n77, n78. PH 5G uses n41/n78 (supported)."
say "Applying the widest NR-inclusive mode (26) that adb can set..."
for k in preferred_network_mode preferred_network_mode1 preferred_network_mode2; do
  "$ADB" shell "settings put global $k 26" >/dev/null 2>&1 || true
done
NEW="$(verify_setting global preferred_network_mode '^(2[2-9]|3[0-3])(,.*)?$')" \
  && ok "NR enabled in preferred mode ($NEW)" || warn "Mode is '$NEW'; OS re-derived it"
log_run 5g report "mode=$NEW"

if [ "${1:-}" = "--guide" ]; then
  guide
else
  cat <<'TXT'

To ENABLE 5G for a non-Japanese (PH) carrier and LOCK bands you must use the
on-device ServiceMode menu (cannot be scripted: SECRET_CODE denied, no root).
Run  scr01 5g --guide  for an interactive walkthrough, or see
docs/servicemode-band-lock.md.

Note: locking to 5G-only drops the hotspot to NO service where only LTE exists.
TXT
fi
