# ServiceMode: enable 5G and lock bands (on-device)

Band locking and 5G enablement for a non-Japanese carrier cannot be scripted
over adb on this device (no root, SELinux enforcing, `SECRET_CODE` broadcasts
denied to the shell). Do it on the SCR01 touchscreen.

## Steps

1. Open the status/number screen and tap the phone number **10 times** to
   unlock the hidden ServiceMode dial code, then open ServiceMode.
2. **NR settings**: turn the band allow-list **OFF**, set SA/NSA mode **ON**.
3. **Band selection** (optional): keep only **n78** (and **n41**) for the PH.
4. Reboot the device.

## Caution

- "Lock to 5G-only" leaves the hotspot with **no service** wherever only LTE is
  available. For everyday use keep NR/LTE (network mode 26), which `scr01 setup`
  applies automatically.
- Note your original ServiceMode values before changing them.

## Unlock USB debugging (if needed)

Tap the **IMEI** entry 10 times to reveal Developer Options, then enable USB
debugging.
