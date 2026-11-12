#!/usr/bin/env python3
# vpad.py [still|stick] : plugs a virtual Xbox 360 controller in (uinput) until it is killed.
# "stick" turns the left stick slowly; no button is ever pressed. Needs python3-evdev and
# write access to /dev/uinput.
import math, sys, time
from evdev import UInput, AbsInfo, ecodes as e

stick = AbsInfo(0, -32768, 32767, 16, 128, 0)
trigger = AbsInfo(0, 0, 255, 0, 0, 0)
hat = AbsInfo(0, -1, 1, 0, 0, 0)
capabilities = {
    e.EV_KEY: [e.BTN_A, e.BTN_B, e.BTN_X, e.BTN_Y, e.BTN_TL, e.BTN_TR, e.BTN_SELECT, e.BTN_START, e.BTN_MODE,
               e.BTN_THUMBL, e.BTN_THUMBR],
    e.EV_ABS: [(e.ABS_X, stick), (e.ABS_Y, stick), (e.ABS_RX, stick), (e.ABS_RY, stick), (e.ABS_Z, trigger),
               (e.ABS_RZ, trigger), (e.ABS_HAT0X, hat), (e.ABS_HAT0Y, hat)],
}
mode = sys.argv[1] if len(sys.argv) > 1 else "still"
with UInput(capabilities, name="Microsoft X-Box 360 pad", vendor=0x045e, product=0x028e, version=0x110,
            bustype=e.BUS_USB) as pad:
    print("virtual pad", pad.device.path, flush=True)
    n = 0
    try:
        while True:
            if mode == "stick":
                n += 1
                pad.write(e.EV_ABS, e.ABS_X, int(20000 * math.sin(n / 10)))
                pad.write(e.EV_ABS, e.ABS_Y, int(20000 * math.cos(n / 10)))
                pad.syn()
            time.sleep(0.1)
    except KeyboardInterrupt:
        pass
