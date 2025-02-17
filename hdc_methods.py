import numpy as np
import random
import scipy.signal
# from matplotlib import pyplot as plt


def generate_randomHV(n: int, p: float):
    """
    Generates a random hypervector with 'n'-dimension and 'p'-density.

    ### Parameters:
        n : int
            dimension of hypervector
        p : float [0, 1]
            density of hypervector

    Returns a random binary hypervector as a numpy array of integers.
    """

    m = int(n * p)  # number of 1s
    random_HV = np.array([1] * m + [0] * (n - m), dtype=int)
    np.random.shuffle(random_HV)

    return random_HV


def bind(hv1: np.ndarray, hv2: np.ndarray):
    """
    Binds two hypervectors together using XOR and returns the resulting hypervector.

    ### Parameters:
        hv1, hv2 : hypervector (numpy array of integers)
            hypervectors to be bound
    """
    return hv1 ^ hv2


def bundle(hv_arr: np.ndarray):
    """
    Bundles an array of hypervectors and returns the resulting hypervector.
    Results are binarized according to half the length of the array and ties are randomly broken. 

    ### Parameters:
        hv_arr : numpy array of hypervectors
            array of hypervectors to be bundled 
    """
    l = len(hv_arr)
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


def compute_similarity(hv1: np.ndarray, hv2: np.ndarray):
    """
    Returns the cosine similarity of two hypervectors.

    ### Parameters:
        hv1, hv2 : numpy array of integers (hypervector)
            hypervectors to be computed for similarity
    """
    return np.sum(hv1 ^ hv2) / len(hv1)


def generate_randommemory(n: int, p: float, d: int):
    """
    Randomly generates the item memory for 'd' items with 'n'-dimension & 'p'-density hypervectors.

    ### Parameters:
        n : int
            dimension of hypervector
        p : float [0, 1]
            density of hypervector
        d : int
            No. of items in memory
    """
    
    memory = np.zeros((d, n), dtype=int)
    for i in range(d):
        memory[i] = generate_randomHV(n, p)

    return memory


def generate_linearmemory(n: int, p: float, d: int):
    """
    Generates a linear item memory with 'd' items, 'n'-dimension, & 'p'-density hypervectors.
    First and last item will have a cosine similarity of 1.

    ### Parameters:
        n : int
            dimension of hypervector
        p : float [0, 1]
            density of hypervector
        d : int
            No. of items in memory   
    """

    memory = np.zeros((d, n), dtype=int)

    memory[0] = generate_randomHV(n, p)
    memory[d-1] = np.logical_not(memory[0]).astype(int)

    num_active = int(n * p / (d-1)) # TODO: check for equation validity in densities other than 0.5
    rem = (n * p) % (d-1) / (d-1)
    curr_rem = 0
    rem_add = 0
    index_zeros = [x[0] for x in enumerate(memory[0]) if x[1] == 0]
    index_ones = [x[0] for x in enumerate(memory[0]) if x[1] == 1]

    for i in range(1, d-1):
        memory[i] = memory[i-1]
        curr_rem += rem
        if curr_rem >= 1:
            curr_rem -= 1
            rem_add = 1
        else:
            rem_add = 0
        for _ in range(num_active + rem_add):
            memory[i][index_zeros.pop(0)] = 1
            memory[i][index_ones.pop(0)] = 0
     
    return memory


def extract_linearMemory(memory: np.ndarray, value: float, min: float, max: float, levels: int = 64):
    """
    Extracts the hypervector of a value from a linear memory given the minimum/maximum values and levels for quantization.

    ### Parameters:
        memory: numpy array of hypervectors
            single array memory of linear hypervectors (ascending value)
        value : float
            value to be quantized
        min : float
            minimum value of feature for patient
        max : float
            maximum value of feature for patient
        levels: int
            number of quantized levels in memory (including 0); must be more than 1
    """
    quantized_value = (value - min) / ((max - min)  / (levels - 1))

    if int(quantized_value) <= 0:
        return memory[0]
    elif int(quantized_value) >= (levels - 1):
        return memory[-1]
    elif quantized_value - int(quantized_value) < 0.5:
        return memory[int(quantized_value)]   
    else:
        return memory[int(quantized_value) + 1]


def compute_LBP(samples):
    """
    Returns the corresponding LBP value of an array of samples.
    LBP-bit pattern is assumed to be len(samples) - 1.

    ### Parameters:
        samples : array of float
            array of samples from input window
    """

    val_LBP = ""

    for i in range(1, len(samples)):
        if samples[i-1] > samples[i]:
            val_LBP += "0"
        elif samples[i-1] < samples[i]:
            val_LBP += "1"
        else:
            val_LBP += str(random.randint(0,1)) # randomize for ties

    return int(val_LBP, base=2)


def compute_optimizedLBP(window, d):
    """
    Returns an array of corresponding LBP value of a window of samples.
    Optimized for faster training time.

    ### Parameters:
        window : array of float
            array of samples from input window

        d : int
            Number of bits for LBP.
    """

    cont_val_LBP = ""

    for i in range(1, len(window)):
        if window[i-1] > window[i]:
            cont_val_LBP += "0"
        elif window[i-1] < window[i]:
            cont_val_LBP += "1"
        else:
            cont_val_LBP += str(random.randint(0,1)) # randomize for ties

    return np.array([int(cont_val_LBP[i-(d-1):i+1], base=2) for i in range(d, len(window))], dtype=int)


def compute_lineLength(window):
    """
    Returns the corresponding line length value given a window of samples.

    ### Parameters:
        window : array of float
            array of samples in input window
    """

    sum = 0
    for i in range(len(window)):
        if i == 0:
            continue
        else:
            sum += abs(window[i] - window[i-1])
    
    line_length = sum / len(window)

    return line_length


def compute_meanAmp(window):
    """
    Returns the corresponding mean amplitude value of a given window of samples.

    ### Parameters:
        window : array of float
            array of samples in input window
    """
    mean = 0
    npeaks = 0

    for i in range(2, len(window)):
        if window[i-2] <= window[i-1] and window[i-1] >= window[i]:
            mean += window[i-1]
            npeaks += 1

    mean = mean / npeaks

    return mean


def compute_bandPower(window: np.ndarray, fs: int, ws: int):
    """
    Returns an array of the spectral power of EEG-relevant frequency bands given a window of samples of one channel.

    ### Parameters:
        window : numpy ndarray floats
            array of samples in input window of an input channel
        fs : sampling frequency
            number of samples per second
        ws : int
            number of samples in window
        levels : int
            number of quantized levels
        max : int
            max value of mean amplitude, must be divisible by levels
    """
    b_low, a_low = scipy.signal.iirfilter(4, Wn=0.5, fs=fs, btype="low", ftype="butter")
    b_delta, a_delta = scipy.signal.iirfilter(4, Wn=[0.5, 4], fs=fs, btype="band", ftype="butter")
    b_theta, a_theta = scipy.signal.iirfilter(4, Wn=[4, 8], fs=fs, btype="band", ftype="butter")
    b_alpha, a_alpha = scipy.signal.iirfilter(4, Wn=[8, 12], fs=fs, btype="band", ftype="butter")
    b_beta, a_beta = scipy.signal.iirfilter(4, Wn=[12, 30], fs=fs, btype="band", ftype="butter")
    b_gamma, a_gamma = scipy.signal.iirfilter(4, Wn=[30, 45], fs=fs, btype="band", ftype="butter")

    ts = np.arange(0, ws/fs, 1.0 / fs)

    window_low = scipy.signal.filtfilt(b_low, a_low, window)
    window_delta = scipy.signal.filtfilt(b_delta, a_delta, window)
    window_theta = scipy.signal.filtfilt(b_theta, a_theta, window)
    window_alpha = scipy.signal.filtfilt(b_alpha, a_alpha, window)
    window_beta = scipy.signal.filtfilt(b_beta, a_beta, window)
    window_gamma = scipy.signal.filtfilt(b_gamma, a_gamma, window)
    
    result = []

    winsq_low = 0
    winsq_delta = 0
    winsq_theta = 0
    winsq_alpha = 0
    winsq_beta = 0
    winsq_gamma = 0

    for i in range(len(window)):
        winsq_low += window_low[i]**2
        winsq_delta += window_delta[i]**2
        winsq_theta += window_theta[i]**2
        winsq_alpha += window_alpha[i]**2
        winsq_beta += window_beta[i]**2
        winsq_gamma += window_gamma[i]**2

    result = [winsq_low, winsq_delta, winsq_theta, winsq_alpha, winsq_beta, winsq_gamma]

    # plt.figure(figsize=[6.4, 2.4])
    # plt.plot(ts, window, label="Raw signal")
    # plt.plot(ts, window_low, label="Low filtered")
    # plt.plot(ts, window_delta, label="Delta filtered")
    # plt.plot(ts, window_theta, label="Theta filtered")
    # plt.plot(ts, window_alpha, label="Alpha filtered")
    # plt.plot(ts, window_beta, label="Beta filtered")
    # plt.plot(ts, window_gamma, label="Gamma filtered")
    # plt.legend(loc="lower center", bbox_to_anchor=[0.5, 1], ncol=3,
    #         fontsize="smaller")
    # plt.xlabel("Time / s")
    # plt.ylabel("Amplitude")

    # plt.tight_layout()
    # # plt.savefig("lowpass-filtfilt.png", dpi=100)
    # plt.show()

    return result