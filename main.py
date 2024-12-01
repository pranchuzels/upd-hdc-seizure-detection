import os
import mne
import numpy as np
import hdc_methods as hdc
from tqdm import tqdm


def extract_npy(filepath):
    with open(filepath, 'rb') as f:
        label_chs = np.load(f)
        value_chs = np.load(f)
        last_samp = np.load(f)
        samp_freq = np.load(f) 
    
    return label_chs, value_chs, last_samp, samp_freq


def pop_sample(value_chs, num_chs, counter_data):

    sample_chs = []
    for i in range(num_chs):
        sample_chs.append(value_chs[i][counter_data])

    return sample_chs


def push_window(sample_chs, window_chs, num_chs, max_size):

    for i in range(num_chs):
    
        if len(window_chs[i]) == max_size:
            window_chs[i].pop(0)

        window_chs[i].append(sample_chs[i])

    return window_chs


def process_windowHV_LBP(window_chs, memory_LBP, memory_chs, num_chs, n, window_size, d):
    arr_sampleHVs = np.zeros((window_size, n), dtype=int)

    for i in range(d, (window_size + d)):
        sum_hv = np.zeros((num_chs, n), dtype=int)
        for j in range(num_chs):
            hv_lbp = hdc.get_LBP(window_chs[j], memory_LBP, d, i)
            sum_hv[j] = hdc.bind(hv_lbp, memory_chs[j])

        arr_sampleHVs[i-d] = hdc.bundle(sum_hv, n, num_chs)

    return hdc.bundle(arr_sampleHVs, n, window_size)

    
def train_file(parameters, data, memory, label_hv, filename):
    n, window_size, window_step, d, feature_set = parameters
    name_chs, value_chs, last_samp, samp_freq = data
    

    counter_step = 0
    window_chs = [[] for _ in range(num_chs)]

    for index_curr_sample in tqdm(range(last_samp + 1), desc=filename, leave=False):

        sample_chs = pop_sample(value_chs, num_chs, index_curr_sample)

        window_chs = push_window(sample_chs, window_chs, num_chs, window_size+d) # TODO: Change max size if not LBP
        counter_step += 1

        if counter_step >= window_step and len(window_chs[0]) == (window_size+d): # TODO: Change size if not LBP
            match feature_set:

                case 1:
                    memory_LBP, memory_chs = memory
                    hv_chs = process_windowHV_LBP(window_chs, memory_LBP, memory_chs, num_chs, n, window_size, d)
                case 2:
                    print(1)
                case default:
                    print(1)

            counter_step = 0
            label_hv = hdc.bundle([hv_chs, label_hv], n, 2)


    return label_hv

if __name__ == "__main__":
    
    # parameters
    n = 2048 # dimension of HV
    window_size = 256 # (1.0 seconds)
    window_step = 128 # 0.5 seconds
    d = 6 # LBP bit size
    feature_set = 1
    num_chs = 17 # constant

    match feature_set:
        case 1:
            memory_LBP = hdc.generate_memory(n, 0.5, 2**d)
            memory_chs = hdc.generate_memory(n, 0.5, num_chs)
            memory = memory_LBP, memory_chs
        case 2:
            print(1)
        case default:
            print(1)

    non_seizure_hv = np.zeros(n, dtype=int)
    np.set_printoptions(edgeitems=20)
    #train non-seizures
    for filename in tqdm(os.listdir("chbmit-eeg-processed/non-seizures"), desc="Training all non-seizures.", leave=False):
        filepath = "chbmit-eeg-processed/non-seizures/" + filename
        
        name_chs, value_chs, last_samp, samp_freq = extract_npy(filepath)
        
        parameters = n, window_size, window_step, d, feature_set
        data = name_chs, value_chs, last_samp, samp_freq

        non_seizure_hv = train_file(parameters, data, memory, non_seizure_hv, filename)
        print(non_seizure_hv)






            

    

