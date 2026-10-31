#!/usr/bin/env bash
# scr01-reset.sh - factory reset (erase userdata) the SCR01 WITHOUT SamFW,
# using a locally built Thor (Odin protocol). If the device is in normal adb
# mode it is rebooted into download mode first. Destructive: wipes user data.
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$HERE/lib/common.sh"

THOR="${SCR01_THOR:-$HOME/.local/share/scr01/thor/TheAirBlow.Thor.Shell}"
if [ ! -x "$THOR" ]; then
  warn "Thor not found at $THOR"
  ask "Build it now from source (needs git + dotnet-sdk-8.0)?" || { err "Cannot reset without Thor."; exit 1; }
  bash "$HERE/tools/build-thor.sh"
fi

warn "This ERASES all user data on the SCR01 and returns it to factory state."
ask "Continue?" || { say "Cancelled."; exit 0; }

if ! download_present; then
  if adb_present; then
    say "Rebooting the device into download mode..."
    "$ADB" reboot download || true
    say "Waiting for download mode (put the device in Download mode if prompted)..."
    for _ in $(seq 1 30); do download_present && break; sleep 2; done
  fi
fi
download_present || { err "No device in download mode. Enter it manually (Vol-Down + power while plugging USB) and re-run."; exit 1; }

ok "Download-mode device detected. Starting erase..."
sudo python3 -I "$HERE/tools/thor-erase.py" "$THOR"
ok "Reset done. When it reboots, run:  scr01 setup   to restore English + 5G."
