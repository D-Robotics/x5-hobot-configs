#!/usr/bin/env python3
import os
import json
from time import sleep

import os
import time

def gpio_control(pin, value, active="low"):
    """
    Control the GPIO pin level by operating the interfaces under /sys/class/gpio,
    and release the pin after operation completed. 

    :param pin: GPIO pin number
    :param value: GPIO level value, 0 for low, 1 for high
    :param active: Active level of the GPIO, default to low level
    :return: None
    """
    # Define the path of GPIO and the corresponding files
    gpio_path = '/sys/class/gpio/gpio{}'.format(pin)
    value_file = os.path.join(gpio_path, 'value')
    direction_file = os.path.join(gpio_path, 'direction')

    # Export the GPIO pin if it has not been exported
    if not os.path.exists(gpio_path):
        with open('/sys/class/gpio/export', 'w') as f:
            f.write(str(pin))

    # Set the GPIO pin direction to output
    with open(direction_file, 'w') as f:
        f.write('out')

    # Set the active level of GPIO
    if active.lower() == 'high':
        value = str(int(not value))

    # Control the GPIO level
    with open(value_file, 'w') as f:
        f.write(str(value))

    # Wait for 0.01s to ensure successful GPIO control
    time.sleep(0.01)

    # Release the GPIO pin
    with open('/sys/class/gpio/unexport', 'w') as f:
        f.write(str(pin))


if __name__ == '__main__':
    with open("/sys/class/socinfo/soc_name", 'r') as f:
        soc_name = f.read().strip()

    if "x5" in soc_name.lower():
        print("X5 do not need.")
        exit(0)

