#!/usr/bin/env bash
# scr01-setup.sh - "start as new": set English language + keyboard and a
# 5G-preferred network mode over adb (no root). Verifies each change by
# read-back and records the outcome to the run log. Safe to re-run.
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$HERE/lib/common.sh"
require_adb
fails=0

say "Setting system locale to English (US)..."
"$ADB" shell "settings put system system_locales en-US" >/dev/null
"$ADB" shell "setprop persist.sys.locale en-US" >/dev/null 2>&1 || true
"$ADB" shell "am broadcast -a android.intent.action.LOCALE_CHANGED" >/dev/null 2>&1 || true
loc="$(verify_setting system system_locales '^en-US$')" \
  && ok "Locale verified -> $loc" || { err "Locale is '$loc', expected en-US"; fails=$((fails+1)); }

say "Ensuring Samsung keyboard is English (US)..."
IME="com.samsung.android.honeyboard/.service.HoneyBoardService"
"$ADB" shell "ime enable $IME" >/dev/null 2>&1 || true
"$ADB" shell "ime set $IME"    >/dev/null 2>&1 || true
"$ADB" shell "settings put system honey_board_input_languages en-US" >/dev/null 2>&1 || true
ime="$(verify_setting secure default_input_method 'honeyboard')" \
  && ok "Keyboard verified -> HoneyBoard" || { err "IME is '$ime'"; fails=$((fails+1)); }

say "Preferring a 5G (NR) network mode on both SIM slots..."
for k in preferred_network_mode preferred_network_mode1 preferred_network_mode2; do
  "$ADB" shell "settings put global $k 26" >/dev/null 2>&1 || true
done
mode="$(verify_setting global preferred_network_mode '^(2[2-9]|3[0-3])(,.*)?$')" \
  && ok "Network mode verified -> $mode (NR/5G included)" \
  || { warn "Network mode is '$mode'; OS may have re-derived it (see scr01 5g)"; fails=$((fails+1)); }

if [ "$fails" -eq 0 ]; then
  ok "Setup complete and verified: English + 5G-preferred."
  log_run setup ok "locale=$loc ime=ok mode=$mode"
else
  warn "Setup finished with $fails unverified item(s)."
  log_run setup partial "fails=$fails locale=$loc mode=$mode"
fi
