#!/usr/bin/env python3
""" Serial communication """

import time
import serial
import sys

ser = serial.serial_for_url("spy:///dev/ttyUSB1?file=test.txt", timeout=1, baudrate=115200)

time.sleep(1)

value = b""
msg = ""
while True:
    size = 1
    cmd = str.encode(input(">> "))
    size = len(cmd)
    if cmd == b"exit":
        sys.exit()
    for char in str(cmd)[2:-1]:
        print(char)
        ser.write(str.encode(char))
        time.sleep(0.001)
    # value = ser.read(size)
    if value != b"":
        try:
            print(value.decode("ascii"))
        except:
            pass
print("\n")
