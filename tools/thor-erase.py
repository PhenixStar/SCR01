#!/usr/bin/env python3
# thor-erase.py - drive Thor's interactive shell to erase the userdata
# partition (a true factory reset) on an SCR01 already in DOWNLOAD mode.
# Pure Odin protocol, no SamFW. Run as root (USB access). Usage:
#   sudo python3 thor-erase.py /path/to/TheAirBlow.Thor.Shell
import sys, time
try:
    import pexpect
except ImportError:
    sys.exit("Need python3 pexpect: pip install pexpect (or apt install python3-pexpect)")

thor = sys.argv[1] if len(sys.argv) > 1 else None
if not thor:
    sys.exit("usage: thor-erase.py <path-to-TheAirBlow.Thor.Shell>")

c = pexpect.spawn(thor, encoding=None, timeout=120, dimensions=(40, 160),
                  env={"TERM": "xterm-256color", "HOME": "/root",
                       "PATH": "/usr/bin:/bin", "DOTNET_CLI_TELEMETRY_OPTOUT": "1"})
c.logfile_read = sys.stdout.buffer

def step(send, pat, t=120):
    c.expect(pat, timeout=t); time.sleep(0.5); c.send(send)

try:
    step("connect\r", r"shell> ")
    step("\r", r"Choose a device")          # only device = SCR01 in download mode
    step("begin odin\r", r"shell> ")
    step("factoryReset\r", r"shell> ")
    step("y\r", r"absolutely")
    step("reboot normal\r", r"shell> ", t=900)   # wait out the erase, then reboot
    step("exit\r", r"shell> ")
    c.expect(pexpect.EOF, timeout=30)
    print("\n[+] userdata erased; device rebooting")
except pexpect.TIMEOUT:
    sys.exit("\n[x] timed out - check the device is in download mode and cable is data-capable")
