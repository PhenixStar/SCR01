#!/usr/bin/env bash
# scr01-reset.sh - factory reset (erase userdata) the SCR01 WITHOUT SamFW,
# using a locally built Thor (Odin protocol). Runs a preflight gate first and
# logs the outcome. Destructive: wipes user data.
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$HERE/lib/common.sh"

THOR="${SCR01_THOR:-$HOME/.local/share/scr01/thor/TheAirBlow.Thor.Shell}"

# --- preflight ---------------------------------------------------------------
say "Preflight checks..."
pf_ok=1
if [ -x "$THOR" ]; then ok "Thor flasher present"; else
  warn "Thor not found at $THOR"
  if ask "Build it now from source (needs git + dotnet-sdk-8.0)?"; then
    bash "$HERE/tools/build-thor.sh" && ok "Thor built" || { err "Build failed"; pf_ok=0; }
  else pf_ok=0; fi
fi
command -v python3 >/dev/null && python3 -c "import pexpect" 2>/dev/null \
  && ok "python3 + pexpect present" || { err "Need python3 + pexpect (apt install python3-pexpect)"; pf_ok=0; }
if adb_present; then
  lvl="$(battery_level)"; [ -n "$lvl" ] && { [ "$lvl" -ge 20 ] && ok "Battery ${lvl}%" || { warn "Battery low (${lvl}%); charge before flashing"; }; }
elif download_present; then ok "Device already in download mode"
else warn "Device not seen in adb or download mode yet"; fi
[ "$pf_ok" -eq 1 ] || { err "Preflight failed; aborting."; log_run reset aborted "preflight"; exit 1; }

warn "This ERASES all user data on the SCR01 and returns it to factory state."
ask "Continue?" || { say "Cancelled."; log_run reset cancelled "user"; exit 0; }

if ! download_present && adb_present; then
  say "Rebooting the device into download mode..."
  "$ADB" reboot download || true
  say "Waiting for download mode..."
  for _ in $(seq 1 30); do download_present && break; sleep 2; done
fi
download_present || { err "No download-mode device. Enter it manually (Vol-Down + power while plugging USB) and re-run."; log_run reset failed "no-download-mode"; exit 1; }

ok "Download-mode device detected. Starting erase..."
if sudo python3 -I "$HERE/tools/thor-erase.py" "$THOR"; then
  ok "Reset done. When it reboots, run:  scr01 setup"
  log_run reset ok "erased userdata"
else
  err "Erase did not complete cleanly."; log_run reset failed "thor-erase"; exit 1
fi
