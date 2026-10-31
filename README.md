# SCR01 Toolkit

User-friendly scripts for the **Samsung Galaxy 5G Mobile Wi-Fi SCR01**
(SM-H412J). Reset the device, bring it up "as new" in English, and configure it
toward 5G for Philippine networks over USB debugging (adb).

Reset uses a locally built **Thor** (Odin protocol), so you never download the
full SamFW package. Everything else runs over adb and needs **no root**.

## Quick start

```bash
scr01 setup          # English language + keyboard + 5G-preferred (adb, no root)
scr01 5g [--guide]   # report 5G state; --guide walks the on-device band lock
scr01 apn <carrier>  # guided APN setup (smart|globe|dito): opens screen + values
scr01 reset [--yes]  # factory reset via Thor/Odin, no SamFW (--yes = non-interactive)
scr01 log [N]        # show the last N run-log lines
scr01 build-thor     # first-time: compile the Thor flasher for this CPU
```

Typical flow: `scr01 reset` → finish the on-screen first-boot wizard →
`scr01 setup`.

## Requirements

- Android platform-tools (`adb`) on PATH or in the Android SDK default location;
  USB debugging enabled on the SCR01.
- For `reset` only: `git`, `dotnet-sdk-8.0`, `python3-pexpect`, and root for raw
  USB access. `scr01 build-thor` installs the .NET SDK via apt if missing.

## Documentation

- [docs/device-reference.md](docs/device-reference.md) — verified device facts
  and the constraints that shaped the toolkit.
- [docs/servicemode-band-lock.md](docs/servicemode-band-lock.md) — the on-device
  steps for enabling 5G on a non-Japanese carrier and locking bands.
- [docs/apn.md](docs/apn.md) — Philippine carrier APN values and why they must be
  entered on-device.

## Layout

```
scr01                 front-door dispatcher
scripts/scr01-*.sh    setup / 5g / apn / reset
tools/build-thor.sh   compile Thor from source for this CPU
tools/thor-erase.py   drive Thor's shell to erase userdata (pexpect)
lib/common.sh         shared helpers (adb resolve, prompts, detection)
docs/                 device reference and ServiceMode guide
```

## Credits

Reset is powered by [TheAirBlow's Thor](https://github.com/Samsung-Loki/Thor),
built from source. Device notes build on the community SCR01 guide.

## License

[MIT](LICENSE) © 2026 PhenixStar
