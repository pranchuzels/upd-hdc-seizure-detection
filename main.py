import os, time
import numpy as np
import hdc_methods as hdc
from tqdm import tqdm
from multiprocessing import Pool
from functools import partial


def create_channel_memory(num_chs):
    memory_chs = hdc.generate_memory(n, 0.5, num_chs)
    with open("training-data/memory_channels.npy", 'wb') as f:
        np.save(f, memory_chs)

def create_feature_memory(feature_set, feature_params):

    match feature_set:
        case 1:
            d = feature_params
            memory_LBP = hdc.generate_memory(n, 0.5, 2**d)
            with open("training-data/memory_LBP.npy", 'wb') as f:
                np.save(f, memory_LBP)
        case 2:
            print(1)

        case default:
            print(1)
    

def get_memory(mem_type):
    match mem_type:
        case 0:
            with open ("training-data/memory_channels.npy", 'rb') as f:
                memory_chs = np.load(f)
            return memory_chs
        
        case 1:
            with open ("training-data/memory_LBP.npy", 'rb') as f:
                memory_LBP = np.load(f)
            return memory_LBP
        
        case 2:
            return
        case 3:
            return
        case 4:
            return
        case default:
            return
        

def extract_npy(filepath):
    with open(filepath, 'rb') as f:
        label_chs = np.load(f)
        value_chs = np.load(f)
        last_samp = np.load(f)
        samp_freq = np.load(f) 
    
    return label_chs, value_chs, last_samp, samp_freq


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
            memory_chs, memory_LBP = memory
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

    with Pool(processes=8) as p, tqdm(total=len(window_indexes_arr), desc=filename, leave=False) as pbar:
        for result in p.imap(partial(_train_file_looper, parameters=parameters, value_chs=value_chs, memory=memory), window_indexes_arr, chunksize=1):
            pbar.update()
            pbar.refresh()
            label_hv = hdc.bundle([result, label_hv], 2)


    return label_hv

def train_leave_one_out(parameters, memory, label, list_patients):

    np.set_printoptions(edgeitems=15)
    pbar_all = tqdm(list_patients, desc= f"Training all patients' {label} with leave-one-out approach.", leave=False, total=len(list_patients))
    for patient in pbar_all:

        path_patient = f"chbmit-eeg-processed/{label}/" + patient
        files_patient = os.listdir(path_patient)

        pbar_patient = tqdm(files_patient, leave=False, total=len(files_patient))
        for file_exc in pbar_patient:

            label_hv = np.zeros(n, dtype=int)
            pbar_patient.set_description(f"Now excluding {file_exc}.")

            for file_inc in files_patient:
                if file_inc == file_exc:
                    continue
                else:
                    name_chs, value_chs, last_samp, samp_freq = extract_npy(str(path_patient + "/"+ file_inc))
                    parameters = n, window_size, window_step, d, feature_set
                    data = name_chs, value_chs, last_samp, samp_freq

                    label_hv = train_file(parameters, data, memory, label_hv, file_inc)
                    pbar_all.write(f"Current label hv: {label_hv}")

            
            if label == "seizures":
                directory = f"training-data/{patient}/s_set{feature_set}_{file_exc[:-4]}.npy"
            elif label == "non-seizures":
                directory = f"training-data/{patient}/ns_set{feature_set}_{file_exc[:-4]}.npy"
            with open(directory, 'wb') as f:
                np.save(f, label_hv)
     
def test(test_filepath, parameters, memory, seizure_filepath, non_seizure_filepath):
    _, _, patient, patient_file = test_filepath.split("/")
    name_chs, value_chs, last_samp, samp_freq = extract_npy(test_filepath)
    n, window_size, window_step, d, feature_set = parameters

    num_chs = len(value_chs)
    window_indexes_arr = []
    for i in range(last_samp+1):
        if (i + 1) % window_step == d and i+d >= window_size + d:
            window_indexes_arr.append(i)

    with open(seizure_filepath, 'rb') as f:
        seizure_hv = np.load(f)

    with open(non_seizure_filepath, 'rb') as f:
        non_seizure_hv = np.load(f)


    num_seiz = 0
    num_non_seiz = 0
    with Pool(processes=8) as p, tqdm(total=len(window_indexes_arr), desc=patient_file, leave=False) as pbar:
        for result in p.imap(partial(_train_file_looper, parameters=parameters, value_chs=value_chs, memory=memory), window_indexes_arr, chunksize=1):
            pbar.update()
            pbar.refresh()
            sim_seizure = hdc.compute_similarity(result, seizure_hv, n)
            sim_non_seizure = hdc.compute_similarity(result, non_seizure_hv, n)

            if sim_seizure <= sim_non_seizure:
                num_seiz += 1
            else:
                num_non_seiz += 1

    print(f"No. of seizure windows: {num_seiz}, No. of non-seizure windows: {num_non_seiz}")



    return num_seiz, num_non_seiz


if __name__ == "__main__":
    
    # parameters
    n = 2048 # dimension of HV
    window_size = 256 # (1.0 seconds)
    window_step = 128 # 0.5 seconds
    d = 6 # LBP bit size
    feature_set = 1
    num_chs = 17 # constant

    # create_channel_memory(num_chs=num_chs)
    # create_feature_memory(feature_set, feature_params = d)

    parameters = n, window_size, window_step, d, feature_set
    list_patients = ["chb02"]

    # train_leave_one_out(parameters=parameters,
    #                     memory= [get_memory(0), get_memory(1)], 
    #                     label="non-seizures", 
    #                     list_patients=list_patients)
    
    # train_leave_one_out(parameters=parameters,
    #                     memory= [get_memory(0), get_memory(1)], 
    #                     label="seizures", 
    #                     list_patients=list_patients)

    test_list = [
        ("chb01/chb01_03_0.npy", "chb01/chb01_03.npy", "chb01/s_set1_chb01_03_0.npy", "chb01/ns_set1_chb01_03.npy"),
        ("chb01/chb01_04_0.npy", "chb01/chb01_04.npy", "chb01/s_set1_chb01_04_0.npy", "chb01/ns_set1_chb01_04.npy"),
        ("chb01/chb01_15_0.npy", "chb01/chb01_15.npy", "chb01/s_set1_chb01_15_0.npy", "chb01/ns_set1_chb01_15.npy"),
        ("chb01/chb01_16_0.npy", "chb01/chb01_16.npy", "chb01/s_set1_chb01_16_0.npy", "chb01/ns_set1_chb01_16.npy"),
        ("chb01/chb01_18_0.npy", "chb01/chb01_18.npy", "chb01/s_set1_chb01_18_0.npy", "chb01/ns_set1_chb01_18.npy"),
        ("chb01/chb01_21_0.npy", "chb01/chb01_21.npy", "chb01/s_set1_chb01_21_0.npy", "chb01/ns_set1_chb01_21.npy"),
        ("chb01/chb01_26_0.npy", "chb01/chb01_26.npy", "chb01/s_set1_chb01_26_0.npy", "chb01/ns_set1_chb01_26.npy")
    ]

    for set in test_list:
        num_seiz, num_non_seiz = test("chbmit-eeg-processed/seizures/"+set[0], 
            parameters, 
            [get_memory(0), get_memory(1)], 
            str("training-data/"+set[2]),
            str("training-data/"+set[3]))

        num_seiz, num_non_seiz = test("chbmit-eeg-processed/non-seizures/"+set[1], 
            parameters, 
            [get_memory(0), get_memory(1)], 
            str("training-data/"+set[2]),
            str("training-data/"+set[3]))
        
        