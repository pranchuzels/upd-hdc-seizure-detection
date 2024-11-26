import mne
import numpy as np
import hdc_methods as hdc

file = "chbmit-eeg\\chb01_01.edf"


def pop_sample(value_chs, num_chs, counter_data):

    sample_chs = []
    for i in range(num_chs):
        sample_chs.append(value_chs[i][counter_data])

    return sample_chs, counter_data+1


def push_window(sample_chs, window_chs, num_chs):

    for i in range(num_chs):
    
        if len(window_chs[i]) == 7:
            window_chs[i].pop(0)

        window_chs[i].append(sample_chs[i])

    return window_chs


def process_window(window_chs, memory_LBP):

    for window in window_chs:
        hv_lbp = hdc.extract_LBP(window, memory_LBP)
        print(hv_lbp)
        # hv_ll = hdc.extract_lineLength(window)
        # hv_mp = hdc.extract_meanAmp(window)



            

if __name__ == "__main__":
    fulldata = mne.io.read_raw_edf(file)
    
    value_chs = fulldata.get_data()
    info_data = fulldata.info
    label_chs = fulldata.ch_names
    num_chs = len(label_chs)
    counter_data = 0
    n = 2048

    window_size = 7
    d = window_size - 1
    memory_LBP = hdc.generate_LBPMemory(n, 0.5, d)


    
    window_chs = [[]*window_size for _ in range(num_chs)]

    for i in range(8):

        sample_chs, counter_data = pop_sample(value_chs, num_chs, counter_data)

        window_chs = push_window(sample_chs, window_chs, num_chs)

        if len(window_chs[0]) == window_size: # TODO: Barebones condition, edit as needed!
            hv_chs = process_window(window_chs, memory_LBP)

