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
    random_HV = np.array([1] * m + [0] * (n - m))
    np.random.shuffle(random_HV)

    return random_HV

def generate_LBPMemory(n, p, d):
    """
    Generates the item memory for 'd'-bit LBP codes with 'n'-dimension & 'p'-density hypervectors.

    Parameters:
        n : int
            dimension of hypervector
        p : float [0, 1]
            density of hypervector
        d : int
            # of bits for LBP codes

    Returns:
        memory_LBP : 
    """
    num_LBP = 2**d
    
    memory_LBP  = np.zeros((num_LBP, n))
    for i in range(num_LBP):
        memory_LBP[i] = generate_randomHV(n, p)

    return memory_LBP 




def extract_LBP(window, memory_LBP):
    val_LBP = ""

    for i in range(len(window)):

        if i == 0:
            continue
        else:
            if window[i-1] > window[i]:
                val_LBP += "0"
            elif window[i-1] < window[i]:
                val_LBP += "1"
            else:
                val_LBP += str(random.randint(0,1))

    val_LBP = int(val_LBP, base=2)

    return memory_LBP[val_LBP]

def extract_lineLength(window):
    return

def extract_meanAmp(window):
    return

def extract_bandPower(window):
    return