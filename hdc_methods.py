import numpy as np
import random

def generate_randomHV(n, p):
    """
    Generates a random hypervector with 'n'-dimension and 'p'-density.

    Parameters:
        n : int
            dimension of hypervector
        p : float [0, 1]
            density of hypervector

    Returns:
        random_HV : binary ndarray (n,)
            random hypervector
    """

    m = int(n * p)  # number of 1s
    random_HV = np.array([1] * m + [0] * (n - m), dtype=int)
    np.random.shuffle(random_HV)

    return random_HV


def bind(hv1, hv2):
    return hv1 ^ hv2

def bundle(hv_arr, l):
    sum_hv = np.sum(hv_arr, axis=0)

    with np.nditer(sum_hv, op_flags=['readwrite']) as it:
        for x in it:
            if x > l/2:
                x[...] = 1
            elif x == l/2:
                x[...] = random.randint(0,1)
            else:
                x[...] = 0

    return sum_hv

def generate_memory(n, p, d):
    """
    Generates the item memory for 'd' items with 'n'-dimension & 'p'-density hypervectors.

    Parameters:
        n : int
            dimension of hypervector
        p : float [0, 1]
            density of hypervector
        d : int
            # of bits for LBP codes

    Returns:
        
    """
    
    memory = np.zeros((d, n), dtype=int)
    for i in range(d):
        memory[i] = generate_randomHV(n, p)

    return memory


def get_LBP(window, memory_LBP, d, i):
    val_LBP = ""

    for j in range(-d+1, 1):
        if window[(j+i)-1] > window[(j+i)]:
            val_LBP += "0"
        elif window[(j+i)-1] < window[(j+i)]:
            val_LBP += "1"
        else:
            val_LBP += str(random.randint(0,1))

    val_LBP = int(val_LBP, base=2)

    return memory_LBP[val_LBP]

def get_lineLength(window):
    return

def get_meanAmp(window):
    return

def get_bandPower(window):
    return