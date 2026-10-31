# APN setup (Philippine carriers)

Writing APNs over adb is **blocked** on this device: the telephony provider
requires `WRITE_APN_SETTINGS`, which the shell user lacks (verified — the
`content insert` call returns `SecurityException: No permission to access APN
settings`). `scr01 apn` therefore opens the APN screen for you and prints the
exact values to type.

Run `scr01 apn smart|globe|dito`. Values below are the common defaults; confirm
against your own plan.

| Carrier | Name | APN | User / Pass | MCC/MNC |
|---|---|---|---|---|
| Smart / TNT / Sun | Smart Internet | `internet` | (blank) | 515/03 |
| Globe / TM | Globe Internet | `internet.globe.com.ph` | globe / globe | 515/02 |
| DITO | DITO | `dito` | (blank) | 515/66 |

After saving, select the new APN and toggle mobile data off and on.
