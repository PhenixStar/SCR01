# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[0.1.0]: https://github.com/PhenixStar/SCR01/releases/tag/v0.1.0
