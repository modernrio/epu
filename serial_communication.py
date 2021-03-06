#!/usr/bin/env python3

from pynput.keyboard import Key, Listener
import serial
import time
import sys

device = "/dev/ttyUSB1" # Device for serial communication
ser = serial.serial_for_url("spy://" + device + "?file=uart_log.txt", timeout=1, baudrate=9600)

def on_press(key):
    # print('{0} pressed'.format(key))
    if len(str(key)) == 3:
        code = str(key)[1]
        ser.write(str.encode(code))
    elif str(key) == "Key.enter":
        ser.write(str.encode("\n"))
    elif str(key) == "Key.backspace":
        ser.write(str.encode("\b"))
    elif str(key) == "Key.space":
        ser.write(str.encode(" "))
    time.sleep(0.01)

def on_release(key):
    # print('{0} release'.format(key))
    if key == Key.esc:
        # Stop listener
        return False

# Collect events until released
with Listener(
        on_press=on_press,
        on_release=on_release) as listener:
    listener.join()

sys.stdin.flush()
