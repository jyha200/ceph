#!/bin/python3

import serial
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--command', '-c', type=str, required=True)
args = parser.parse_args()


signal=bytes(args.command, 'utf-8')

brd = serial.Serial('/dev/ttyUSB0', 115200, timeout=0.1)
brd.write(signal)

#3.3/5.0/12.o0V config
# Action: turn on/ Turn off
# 3.3V - b'C'/
# 5.V b'N'
# 5.V b'g'
# port #1 J/j
# port #2 K/k
# port #3 L/l
# port #4 M/mr
