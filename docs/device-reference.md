# SCR01 device reference

Verified over adb on a KDI/au unit.

| Property | Value |
|---|---|
| Model | `SCR01` (SM-H412J) |
| Product name | `SCR01_jp_kdi` |
| CSC / carrier | `KDI` (au / KDDI, Japan) |
| Baseband | `SCR01KDU1AVK2` |
| Android | 11 (SDK 30), One UI 3.0, no Google Play Services |
| SoC | MediaTek Dimensity 720 |
| Factory locale | `ja-JP` (returns after every wipe) |
| Root | none; SELinux enforcing |

## Radio

- 5G NR bands fixed in hardware: **n28, n41, n77, n78**.
- Philippine 5G (Smart, Globe) uses **n41** and **n78**; both are supported, so
  the unit is already PH-5G-capable.
- `preferred_network_mode` observed as `24,26` (both NR-inclusive); `5gStatus=1`.

## Constraints that shaped the toolkit

- The shell user (uid 2000) cannot write secure/system settings or send
  system-only broadcasts such as `MASTER_CLEAR`.
- The hidden ServiceMode band menu cannot be opened from adb: the
  `android.provider.Telephony.SECRET_CODE` broadcast is denied to the shell.
  Band locking is therefore an on-device step; see
  [servicemode-band-lock.md](servicemode-band-lock.md).

## Verified shell-user capabilities (on-device, 2026-11-03)

Confirmed against a connected unit, settling the paths that shipped in v0.4.0
without live hardware:

- **`ping` is permitted** to the shell user. `ping -c 3 8.8.8.8` runs; with no
  SIM it returns `connect: Network is unreachable` (rc 2) — a routing error, not
  a SELinux `Permission denied`. So `scr01 apn --verify` can rely on ICMP as its
  data-path check, and a failure there means no APN/SIM/signal, not a sandbox
  block.
- **`settings get` read-backs are accurate.** `scr01 setup --check` reported the
  live `system_locales` (`en-US`), input method (HoneyBoard), and
  `preferred_network_mode` (`24,26`) exactly, changed nothing, and exited 0.
