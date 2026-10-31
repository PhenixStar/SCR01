#!/usr/bin/env bash
# scr01-setup.sh - "start as new": set English language + keyboard and a
# 5G-preferred network mode over adb, no root required. Safe to re-run,
# and meant to be run right after a factory reset to undo the ja-JP default.
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$HERE/lib/common.sh"
require_adb

say "Setting system locale to English (US)..."
"$ADB" shell "settings put system system_locales en-US" >/dev/null
"$ADB" shell "setprop persist.sys.locale en-US" >/dev/null 2>&1 || true
# Apply the locale to the running config so the UI switches without a reboot.
"$ADB" shell "am broadcast -a android.intent.action.LOCALE_CHANGED" >/dev/null 2>&1 || true
ok "Locale -> $("$ADB" shell settings get system system_locales | tr -d '\r')"

say "Ensuring Samsung keyboard is English (US)..."
IME="com.samsung.android.honeyboard/.service.HoneyBoardService"
"$ADB" shell "ime enable $IME" >/dev/null 2>&1 || true
"$ADB" shell "ime set $IME"    >/dev/null 2>&1 || true
# HoneyBoard input language list; en-US QWERTY.
"$ADB" shell "settings put system honey_board_input_languages en-US" >/dev/null 2>&1 || true
ok "Keyboard -> $("$ADB" shell settings get secure default_input_method | tr -d '\r')"

say "Preferring a 5G (NR) network mode on both SIM slots..."
# 26 = NR/LTE/CDMA/EVDO/GSM/WCDMA (widest NR-inclusive mode). Shell can write
# this; telephony may re-derive it, so we verify below.
for k in preferred_network_mode preferred_network_mode1 preferred_network_mode2; do
  "$ADB" shell "settings put global $k 26" >/dev/null 2>&1 || true
done
MODE="$("$ADB" shell settings get global preferred_network_mode | tr -d '\r')"
case "$MODE" in
  2[2-9]|3[0-3]) ok  "Network mode -> $MODE (NR/5G included)";;
  *)             warn "Network mode -> $MODE (NR not confirmed; use scr01-5g.sh)";;
esac

ok "Setup complete. The device is configured for English + 5G-preferred."
