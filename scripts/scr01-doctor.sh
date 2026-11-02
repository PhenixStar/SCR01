#!/usr/bin/env bash
# scr01-doctor.sh - read-only readiness report. Tells you which subcommands are
# ready to run: adb/download state, Thor build, reset dependencies, battery, and
# the device's current locale/keyboard/network mode. Changes nothing.
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$HERE/lib/common.sh"

THOR="${SCR01_THOR:-$HOME/.local/share/scr01/thor/TheAirBlow.Thor.Shell}"
issues=0

say "SCR01 doctor - environment readiness (read-only)"
echo

# --- host tooling ------------------------------------------------------------
say "Host tooling"
ok "adb resolved -> $ADB"
if command -v python3 >/dev/null && python3 -c "import pexpect" 2>/dev/null; then
  ok "python3 + pexpect present (reset ready)"
else
  warn "python3 + pexpect missing (reset needs: apt install python3-pexpect)"; issues=$((issues+1))
fi
if command -v dotnet >/dev/null; then ok "dotnet present ($(dotnet --version 2>/dev/null))"
else warn "dotnet not on PATH (build-thor installs dotnet-sdk-8.0 if needed)"; fi
if [ -x "$THOR" ]; then ok "Thor flasher built -> $THOR"
else warn "Thor not built yet (run: scr01 build-thor) -> $THOR"; fi
echo

# --- device state ------------------------------------------------------------
say "Device state"
if adb_present; then
  model="$("$ADB" shell getprop ro.product.model 2>/dev/null | tr -d '\r')"
  ok "In adb mode (model: ${model:-unknown}) - setup / 5g / apn ready"
  lvl="$(battery_level)"
  if [ -n "$lvl" ]; then
    [ "$lvl" -ge 20 ] && ok "Battery ${lvl}%" || warn "Battery low (${lvl}%); charge before a reset/flash"
  fi
elif download_present; then
  ok "In download/Odin mode - reset ready (setup/5g/apn need adb mode)"
else
  warn "No device in adb or download mode"; issues=$((issues+1))
fi
echo

# --- current configuration (only meaningful in adb mode) ---------------------
if adb_present; then
  say "Current configuration"
  loc="$(verify_setting system system_locales '^en-US$')" \
    && ok "Locale: $loc (English US)" || warn "Locale: ${loc:-unset} (run scr01 setup for en-US)"
  ime="$(verify_setting secure default_input_method 'honeyboard')" \
    && ok "Keyboard: HoneyBoard" || warn "Keyboard: ${ime:-unset}"
  mode="$(verify_setting global preferred_network_mode '^(2[2-9]|3[0-3])(,.*)?$')" \
    && ok "Network mode: $mode (NR/5G included)" || warn "Network mode: ${mode:-unset} (see scr01 5g)"
  echo
fi

if [ "$issues" -eq 0 ]; then
  ok "No blocking issues found."
  log_run doctor ok "adb=$(adb_present && echo y || echo n) thor=$([ -x "$THOR" ] && echo y || echo n)"
else
  warn "$issues item(s) need attention (see above)."
  log_run doctor warn "issues=$issues"
fi
