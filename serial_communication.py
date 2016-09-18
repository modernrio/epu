#!/usr/bin/env python3
import serial
import time

# baudrate = 1500000  # 1.5Mbit/s
# baudrate = 12000000 # 12Mbit/s

# One byte takes 10 bits so 10Mbit/s may almost equal 1.0MByte/s.

ser = serial.serial_for_url("spy:///dev/ttyUSB1?file=test.txt", timeout=1,
                            baudrate=9600)

time.sleep(1)

msg = ""
value = None
error = 0
try:
    while True:
        # ser.write(char_to_send.encode())
        # print("Send: " + char_to_send)
        oldvalue = value
        value = ser.read()
        if len(value) != 0 and oldvalue != value:
            try:
                msg += value.decode("ascii")
                # if error == 0:
                #     error = 1
                # else:
                #     error = 0
                #     continue
                print(msg[-1], end="", flush=True)
            except:
                pass
except KeyboardInterrupt:
    pass
print("\n")
