# Optimal taps are found here: https://www.physics.otago.ac.nz/reports/electronics/ETR2012-1.pdf

from collections import deque

seed = 0b1000000010000001
size = 16
steps = 30
taps = [16, 14, 13, 11] # taps as defined in link above

taps.reverse()
taps = [x-1 for x in taps] # convert to 0-indexed
msb = 0

seed = deque(list(bin(seed).lstrip("0b")))
for x in range(steps+1):
    if x != 0:
        print(f"Step {x} output: {seed[size-1]}   Register: {"".join(seed)}") # output LSB
        seed.rotate(1) # shift right
        seed[0] = msb # Replace MSB
    msb = int(seed[taps[0]]) ^ int(seed[taps[1]]) ^ int(seed[taps[2]]) ^ int(seed[taps[3]])
        
