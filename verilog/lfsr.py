# Optimal taps are found here: https://www.physics.otago.ac.nz/reports/electronics/ETR2012-1.pdf

import copy
from collections import deque

seed = 0b1001010010110101
starting_seed = copy.deepcopy(seed)
size = 16
steps = 10
taps = [16, 14, 13, 11] # taps as defined in link above

taps.reverse()
taps = [x-1 for x in taps] # convert to 0-indexed
msb = 0

seed = deque(list(bin(seed).lstrip("0b")))


for x in range(steps+1):
    if x != 0:
        print(f"Step {x} output: {seed[size-1]}   Register: {"".join(map(str, seed))}") # output LSB
        seed.rotate(1) # shift right
        seed[0] = msb # Replace MSB
    msb = int(seed[taps[0]]) ^ int(seed[taps[1]]) ^ int(seed[taps[2]]) ^ int(seed[taps[3]])

    if bin(starting_seed) == str("0b" + "".join(map(str, seed))):
        print(f"Same!!")