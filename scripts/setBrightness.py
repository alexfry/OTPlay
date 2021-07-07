#!/usr/bin/env python3

# Script to find the measurement below above the target, lerp between them, and set the display brightness
# Requires brightness script from https://github.com/nriley/brightness
# Just run 'brew install brightness'

import os
import sys

def lerp(v, d):
    return v[0] * (1 - d) + v[1] * d


if len(sys.argv) > 1:
    nits = float(sys.argv[1])
else:
    nits = 100.0
print('Targeting %snits' % nits)

brightnessSamplesPath = os.path.join(os.path.dirname(__file__),'brightnessSamples.csv')


with open(brightnessSamplesPath, 'r') as f:
    data = f.readlines()

# print(data)

data = data[1:]

lowerIndex = 0
upperIndex = -1
for i,d in enumerate(data):
    # print(i)
    if float(d.split(',')[4]) < float(nits):
        lowerIndex = i
for i,d in reversed(list(enumerate(data))):
    # print(i)
    if float(d.split(',')[4]) > float(nits):
        upperIndex = i

print('Measurement below Target')
print(data[lowerIndex])
print('Measurement abopve Target')
print(data[upperIndex])

lowerMeasuredNits = float(data[lowerIndex].split(',')[4])
upperMeasuredNits = float(data[upperIndex].split(',')[4])
valueTransition = (nits - lowerMeasuredNits) / (upperMeasuredNits - lowerMeasuredNits)

# Lerp between lower and upper measurements
interpolatedBrightness = lerp([float(data[lowerIndex].split(',')[0]),float(data[upperIndex].split(',')[0])],valueTransition)
# Drop precision down to 6 decimal places
interpolatedBrightness6dp = float(int(interpolatedBrightness*1000000))/1000000

print('Interpolated Brightness value is')
print(interpolatedBrightness6dp)
# set brightness
os.system('brightness '+ str(interpolatedBrightness6dp))