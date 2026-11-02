# APN setup (Philippine carriers)

Writing APNs over adb is **blocked** on this device: the telephony provider
requires `WRITE_APN_SETTINGS`, which the shell user lacks (verified — the
`content insert` call returns `SecurityException: No permission to access APN
settings`). `scr01 apn` therefore opens the APN screen for you and prints the
values to type.

The SCR01 is a hotspot/dongle, so the dongle-style APN is listed first where it
differs from the phone profile. These are community-documented values; no
official 2026 carrier page was found, so confirm with your carrier.

| Carrier | Name | APN (primary) | APN (alternate) | User/Pass |
|---|---|---|---|---|
| Smart / TNT / Sun | Smart Internet | `internet` (dongle) | `internet.smart.com.ph` (phone) | blank |
| Globe / TM | Globe Internet | `internet.globe.com.ph` (postpaid) | `http.globe.com.ph` (prepaid) | blank |
| DITO | DITO Internet | `internet.dito.ph` | `dito` | blank |

APN type `default,supl` for all. After saving, select the new APN and toggle
mobile data off and on. To confirm it worked, run `scr01 apn --verify`, which
pings a public host over the device's radio and reports whether data is up.
Shell-user `ping` is confirmed permitted on this device (verified on-device
2026-11-03), so a `--verify` failure means the APN, SIM, or signal is the
problem — not a sandbox restriction.

## Sources (community guides, undated/third-party)

- Smart / Globe / Sun: <https://www.yugatech.com/apn-settings-for-globe-smart-sun-cellular/>
- DITO SIM setup and APN: <https://yugatech.com/guides/dito-sim-setup-apn-speed-test-promo>
- All-networks reference: <https://tmsim-9jz.pages.dev/>
