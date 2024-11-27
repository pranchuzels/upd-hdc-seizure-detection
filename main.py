import mne
import numpy as np
import hdc_methods as hdc

file = "chbmit-eeg\\chb01_01.edf"


def pop_sample(value_chs, num_chs, counter_data):

    sample_chs = []
    for i in range(num_chs):
        sample_chs.append(value_chs[i][counter_data])

    return sample_chs, counter_data+1


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

    

        


if __name__ == "__main__":
    fulldata = mne.io.read_raw_edf(file)
    
    value_chs = fulldata.get_data()
    info_data = fulldata.info
    label_chs = fulldata.ch_names
    num_chs = len(label_chs)
    index_curr_sample = 0
    index_max_sample = value_chs.size-1
    n = 2048

    window_size = 256 # 1.0 seconds
    window_step = 128 # 0.5 seconds
    d = 6
    
    feature_set = 1



    match feature_set:
        case 1:
            memory_LBP = hdc.generate_memory(n, 0.5, 2**d)
            memory_chs = hdc.generate_memory(n, 0.5, num_chs)
        case 2:
            print(1)
        case default:
            print(1)


    counter_step = 0
    window_chs = [[] for _ in range(num_chs)]

    while index_curr_sample <= index_max_sample:

        sample_chs, index_curr_sample = pop_sample(value_chs, num_chs, index_curr_sample)
        window_chs = push_window(sample_chs, window_chs, num_chs, window_size+d) # TODO: Change max size if not LBP
        counter_step += 1

        hv_chs = np.zeros((num_chs,n))

        if counter_step >= 128 and len(window_chs[0]) == (window_size+d): # TODO: Change size if not LBP
            match feature_set:
                case 1:
                    hv_chs = process_windowHV_LBP(window_chs, memory_LBP, memory_chs, num_chs, n, window_size, d)
                case 2:
                    print(1)
                case default:
                    print(1)

            counter_step = 0


            

    

