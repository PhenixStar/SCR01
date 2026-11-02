# SCR01 Toolkit — Project Plan & Roadmap

**Status as of 2026-11-02:** Shipped and stable at **v0.4.0**. `main` is in sync
with `origin/main`, the lint CI passes, and releases exist for every version.
The toolkit delivers its core purpose; remaining work is optional enhancement,
not repair.

## Purpose

User-friendly, root-free scripts for the **Samsung Galaxy 5G Mobile Wi-Fi SCR01
(SM-H412J)** — an au/KDDI Japan import. The toolkit factory-resets the device
without downloading SamFW (using a locally built Thor/Odin flasher), brings it
up "as new" in English, and configures it toward 5G for Philippine networks over
adb. Repository: `github.com/PhenixStar/SCR01`.

## Hard constraints (verified, shape every decision)

These were proven by live testing and are not expected to change:

- No root; SELinux enforcing; the adb shell runs as uid 2000. `settings put`
  works and is read-back verifiable, but the APN content-provider write and the
  ServiceMode `SECRET_CODE` broadcast are **denied**.
- 5G/NR is already enabled in `preferred_network_mode`; PH bands (n41/n78) are
  already supported by the fixed hardware band set (n28/n41/n77/n78).
- Band-locking and 5G-only selection are **on-device-only** (ServiceMode); they
  cannot be scripted.
- Thor's prebuilt x86-64 binary crashes under QEMU on the ARM64 host, so Thor is
  built from source (net9.0 → net8.0, linux-arm64) by `scr01 build-thor`.

See `docs/device-reference.md`, `docs/servicemode-band-lock.md`, `docs/apn.md`.

## Completed phases

| Version | Delivered | Acceptance (met) |
|---|---|---|
| v0.1.0 | `scr01` dispatcher; `reset` via locally built Thor; `setup` (English + 5G-preferred); `5g`; `build-thor`; `lib/common.sh`; initial docs. | Each subcommand runs; reset erases userdata via Odin with no SamFW. |
| v0.2.0 | Run log (`scr01 log`); read-back verification in `setup`; `reset` preflight gate; `5g --guide`; guided `apn`. | Changes verify by read-back; reset refuses on failed preflight; outcomes logged. |
| v0.3.0 | `reset --yes` non-interactive mode; corrected PH APN values with primary/alternate and sources. | `--yes` skips prompts; APN values match carrier guides. |
| v0.4.0 | `doctor` readiness report; `apn --verify` connectivity check; `setup --check` dry-run; CI lint (shellcheck + syntax + py_compile). | ShellCheck `-S warning` clean; CI green on push; `doctor` is read-only. |

## Proposed next phases

Ordered by value-per-effort. None are blocking; the toolkit is complete without
them. P6 is done (see below); P5 and P7 remain unstarted.

### P5 — `scr01 start`: guided "new phone" orchestrator
Chain the full lifecycle: `reset` → wait for adb to return → `setup` → `5g`
report → `apn` → `apn --verify`, pausing at the on-screen first-boot wizard
(which cannot be automated).
- **Dependencies:** all component subcommands (already shipped).
- **Acceptance:** one command walks the lifecycle end to end, stops cleanly at
  each manual step with clear instructions, and logs the run.
- **Risk:** the first-boot wizard is human-driven, so this is a guided state
  machine, not a hands-off script. Keep it honest about that.

### P6 — On-device live validation ✅ done 2026-11-03
The device-side paths added in v0.4.0 were verified off-device only; now
confirmed on a connected unit.
- **Result:** shell-user `ping` **is** permitted (SIM-absent gives
  `Network is unreachable` / rc 2, a routing error, not a SELinux denial), so
  `apn --verify` works as designed and did not trip `set -euo pipefail`.
  `setup --check` read `en-US` / HoneyBoard / `24,26` back accurately and
  changed nothing. Recorded in `docs/device-reference.md` and `docs/apn.md`.

### P7 — Install convenience
An `install.sh` that symlinks `scr01` into `~/.local/bin`, plus optional
bash/zsh completion for subcommands.
- **Dependencies:** none.
- **Acceptance:** `scr01` is on PATH after install; completion lists subcommands.

## Non-goals (closed, do not reopen)

- Root-only or custom-recovery features; re-adding the SamFW download.
- Scripted band-lock or forced 5G-only — blocked by SELinux/`SECRET_CODE`;
  remains documented as on-device ServiceMode steps only.
- Supporting devices other than the SM-H412J; any GUI.

## Links

- Release history: `CHANGELOG.md` and `github.com/PhenixStar/SCR01/releases`.
- CI: `.github/workflows/lint.yml`.
- Dispatcher and scripts: `scr01`, `scripts/scr01-*.sh`, `lib/common.sh`.
