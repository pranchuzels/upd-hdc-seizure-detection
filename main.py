import mne
import numpy as np
import feature_extractor as extract

file = "chbmit-eeg\\chb01_01.edf"


def pop_sample(value_chs, num_chs, counter_data):

    sample_chs = []
    for i in range(num_chs):
        sample_chs.append(value_chs[i][counter_data])

    return sample_chs, counter_data+1


def push_window(sample_chs, window_chs):

    for i in range(window_chs):
    
        if len(window_chs[i]) == 7:
            window_chs[i].pop(0)

        window_chs[i].append(sample_chs[i])


def process_window(sample_chs, window_chs):

    for channel in window_chs:
        hv_lbp = extract.LBP(channel)
        hv_ll = extract.line_length(channel)
        hv_mp = extract.mean_amp(channel)
        


            

if __name__ == "__main__":
    fulldata = mne.io.read_raw_edf(file)
    
    value_chs = fulldata.get_data()
    info_data = fulldata.info
    label_chs = fulldata.ch_names
    num_chs = len(label_chs)
    counter_data = 0

    window_size = 7
    window_chs = [[]*window_size for _ in range(num_chs)]

    # for i in range(2):
    #     sample_chs, counter_data = pop_sample(value_chs, label_chs, counter_data)
    #     print(sample_chs)

    sample_chs, counter_data = pop_sample(value_chs, num_chs, counter_data)

    window_chs = push_window(sample_chs, window_chs)

    if len(window_chs[0]) == window_size: # TODO: Barebones condition, edit as needed!
        hv_chs = process_window(window_chs)

