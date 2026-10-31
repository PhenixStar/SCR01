# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-10-31

### Added
- Run log at `~/.local/share/scr01/runs.log`; view with `scr01 log [N]`.
- `scr01 setup` now verifies each change by read-back and records the outcome.
- `scr01 reset` runs a preflight gate (Thor present, python/pexpect, battery,
  device mode) and logs the result.
- `scr01 5g --guide`: interactive walkthrough of the on-device ServiceMode band
  lock.
- `scr01 apn <smart|globe|dito>`: guided Philippine APN setup (opens the APN
  screen and prints exact values; adb APN writes are denied on this device).

## [0.1.0] - 2026-10-31

### Added
- `scr01` dispatcher as the single front door for all tasks.
- `scr01 reset`: factory reset (erase userdata) via a locally built Thor
  (Odin protocol), with no SamFW download.
- `scr01 setup`: restore English language and Samsung keyboard and apply a
  5G-preferred network mode over adb, no root required.
- `scr01 5g`: report radio state, apply the widest NR-inclusive mode adb can
  set, and document the on-device ServiceMode band-lock steps.
- `scr01 build-thor`: compile the Thor flasher from source for this CPU.
- Shared helpers in `lib/common.sh` (adb discovery, prompts, device detection).
- Documentation: README, ServiceMode band-lock guide, device reference.

[0.2.0]: https://github.com/PhenixStar/SCR01/releases/tag/v0.2.0
[0.1.0]: https://github.com/PhenixStar/SCR01/releases/tag/v0.1.0
