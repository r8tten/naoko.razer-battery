#!/usr/bin/env python3

import os
import dbus
from openrazer.client import DeviceManager

CACHE = os.path.expanduser("~/.cache/razer-battery")


def save_battery(value):
    os.makedirs(os.path.dirname(CACHE), exist_ok=True)

    with open(CACHE, "w") as f:
        f.write(str(value))


def load_battery():
    try:
        with open(CACHE, "r") as f:
            return f.read().strip()
    except FileNotFoundError:
        return ""


try:
    dm = DeviceManager()

    battery = None
    charging = False

    for device in dm.devices:
        if "DeathAdder" in device.name:
            power = dbus.Interface(
                device._dbus,
                "razer.device.power"
            )

            battery = round(power.getBattery())
            charging = power.isCharging()
            break

    # DeathAdder reports fake 0% while asleep.
    if battery == 0:
        cached = load_battery()

        if cached:
            battery = int(cached)
        else:
            battery = None

    elif battery is not None:
        save_battery(battery)

    if battery is not None:
        print(f"{battery}|{1 if charging else 0}")
    else:
        print("")

except Exception:
    print("")
