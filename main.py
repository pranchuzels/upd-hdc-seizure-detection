import os
import mne
import numpy as np
import hdc_methods as hdc
from tqdm import tqdm
from multiprocessing import Pool
from functools import partial

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

        arr_sampleHVs[i-d] = hdc.bundle(sum_hv, num_chs)

    return hdc.bundle(arr_sampleHVs, window_size)


def _train_file_looper(index, parameters, value_chs, memory):
    n, window_size, window_step, d, feature_set = parameters
    num_chs = len(value_chs)
    match feature_set:

        case 1:
            window_chs = value_chs[:, index + 1 - (window_size+d): index + 1]
            memory_LBP, memory_chs = memory
            hv_chs = process_windowHV_LBP(window_chs, memory_LBP, memory_chs, num_chs, n, window_size, d)
        case 2:
            print(1)
        case default:
            print(1)

    return hv_chs

def train_file(parameters, data, memory, label_hv, filename):
    n, window_size, window_step, d, feature_set = parameters
    name_chs, value_chs, last_samp, samp_freq = data
    window_indexes_arr = []
    for i in range(last_samp+1):
        if (i + 1) % window_step == d and i+d >= window_size + d:
            window_indexes_arr.append(i)

    with Pool() as p, tqdm(total=len(window_indexes_arr), desc=filename, leave=False) as pbar:
        for result in p.imap(partial(_train_file_looper, parameters=parameters, value_chs=value_chs, memory=memory), window_indexes_arr):
            pbar.update()
            pbar.refresh()
            label_hv = hdc.bundle([result, label_hv], 2)


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
    non_seizure_files = os.listdir("chbmit-eeg-processed/non-seizures")
    for filename in tqdm(non_seizure_files, desc="Training all non-seizures.", leave=False, total=len(non_seizure_files)):
        filepath = "chbmit-eeg-processed/non-seizures/" + filename
        
        name_chs, value_chs, last_samp, samp_freq = extract_npy(filepath)
        
        parameters = n, window_size, window_step, d, feature_set
        data = name_chs, value_chs, last_samp, samp_freq

        non_seizure_hv = train_file(parameters, data, memory, non_seizure_hv, filename)
        print(non_seizure_hv)






            

    

