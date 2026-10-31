#!/usr/bin/env bash
# Shared helpers for the SCR01 toolkit. Sourced by every script.
set -euo pipefail

# Resolve adb: prefer PATH, fall back to the Android SDK location on this machine.
ADB="$(command -v adb 2>/dev/null || true)"
[ -z "$ADB" ] && [ -x "$HOME/Android/Sdk/platform-tools/adb" ] && ADB="$HOME/Android/Sdk/platform-tools/adb"
[ -z "$ADB" ] && [ -x /opt/platform-tools/adb ] && ADB="/opt/platform-tools/adb"
: "${ADB:?adb not found - install Android platform-tools or set ADB=}"

c_grn=$'\e[32m'; c_yel=$'\e[33m'; c_red=$'\e[31m'; c_cyn=$'\e[36m'; c_rst=$'\e[0m'
say()  { printf '%s[*]%s %s\n' "$c_cyn" "$c_rst" "$*"; }
ok()   { printf '%s[+]%s %s\n' "$c_grn" "$c_rst" "$*"; }
warn() { printf '%s[!]%s %s\n' "$c_yel" "$c_rst" "$*"; }
err()  { printf '%s[x]%s %s\n' "$c_red" "$c_rst" "$*" >&2; }
ask()  { local a; read -r -p "$(printf '%s[?]%s %s [y/N] ' "$c_yel" "$c_rst" "$1")" a; [[ "$a" =~ ^[Yy]$ ]]; }

# True when the SCR01 is visible to adb in normal (debugging) mode.
adb_present() { "$ADB" devices | awk 'NR>1 && $2=="device"{f=1} END{exit !f}'; }
# True when a Samsung is enumerated in download/Odin mode (04e8:685d).
download_present() { lsusb 2>/dev/null | grep -qiE '04e8:685d|Download mode'; }


# --- run log -----------------------------------------------------------------
SCR01_LOG="${SCR01_LOG:-$HOME/.local/share/scr01/runs.log}"
log_run() { # log_run <action> <result> <detail...>
  mkdir -p "$(dirname "$SCR01_LOG")" 2>/dev/null || true
  printf '%s\t%s\t%s\t%s\n' "$(date -Is)" "$1" "$2" "${*:3}" >> "$SCR01_LOG" 2>/dev/null || true
}

# verify_setting <namespace> <key> <regex> -> echoes actual value, 0 on match
verify_setting() {
  local got; got="$("$ADB" shell settings get "$1" "$2" 2>/dev/null | tr -d '\r')"
  printf '%s' "$got"
  [[ "$got" =~ $3 ]]
}

# battery_level -> integer 0-100 (or empty)
battery_level() { "$ADB" shell dumpsys battery 2>/dev/null | awk -F': ' '/  level:/{print $2; exit}' | tr -d '\r'; }

require_adb() {
  adb_present || { err "SCR01 not in adb mode. Connect it and enable USB debugging."; exit 1; }
  local m; m="$("$ADB" shell getprop ro.product.model 2>/dev/null | tr -d '\r')"
  [ "$m" = "SCR01" ] || warn "Connected model reports '$m' (expected SCR01). Continuing."
}
