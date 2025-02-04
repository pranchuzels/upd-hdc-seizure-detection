import os, time
import numpy as np
import hdc_methods as hdc
from tqdm import tqdm
from multiprocessing import Pool
from functools import partial


def create_channel_memory(num_chs):
    memory_chs = hdc.generate_randommemory(n, 0.5, num_chs)
    with open("training-data/memory_channels.npy", 'wb') as f:
        np.save(f, memory_chs)


def create_feature_memory(feature_set: int, d: int = 0, levels: int = 0):
    """
    Creates a .npy file in "training-data" subdirectory containing the memory of chosen feature set.

    ### Parameters:
        feature_set : int
            1 = LBP;
            2 = Spectral Power;
            3 = Mean amplitude;
            4 = Line length;

    """
    match feature_set:
        case 1: # LBP
            memory_LBP = hdc.generate_randommemory(n, 0.5, 2**d)
            with open("training-data/memory_LBP.npy", 'wb') as f:
                np.save(f, memory_LBP)
        case 2: # Spectral Power
            memory_spi = hdc.generate_randommemory(n, 0.5, d)
            memory_spv = hdc.generate_linearmemory(n=n, p=0.5, d = levels)
            with open("training-data/memory_sp.npy", 'wb') as f:
                np.save(f, memory_spi)
                np.save(f, memory_spv)
        case 3: # Mean amplitude
            memory_ma = hdc.generate_linearmemory(n=n, p=0.5, d = levels)
            with open("training-data/memory_ma.npy", 'wb') as f:
                np.save(f, memory_ma)
        case 4: # Line length
            memory_ll = hdc.generate_linearmemory(n=n, p=0.5, d = levels)
            with open("training-data/memory_ll.npy", 'wb') as f:
                np.save(f, memory_ll)
    

def get_memory(mem_type):
    match mem_type:
        case 0: # Channels
            with open ("training-data/memory_channels.npy", 'rb') as f:
                memory_chs = np.load(f)
            return memory_chs
        
        case 1: # LBP only
            with open ("training-data/memory_LBP.npy", 'rb') as f:
                memory_LBP = np.load(f)
            return memory_LBP
        
        case 2: # Spectral Power only
            with open ("training-data/memory_sp.npy", 'rb') as f:
                memory_spi = np.load(f)
                memory_spv = np.load(f)
            return [memory_spi, memory_spv]
        
        case 3: # Mean amplitude, Line length. LBP
            with open ("training-data/memory_ma.npy", 'rb') as f:
                memory_ma = np.load(f)
            with open ("training-data/memory_ll.npy", 'rb') as f:
                memory_ll = np.load(f)
            with open ("training-data/memory_LBP.npy", 'rb') as f:
                memory_LBP = np.load(f)
            return memory_ma, memory_ll, memory_LBP
        
        case 4: # Line length & spectral power
            with open ("training-data/memory_ll.npy", 'rb') as f:
                memory_ll = np.load(f)
            with open ("training-data/memory_sp.npy", 'rb') as f:
                memory_sp = np.load(f)
            return memory_ll, memory_sp
        

def extract_npy(filepath):
    with open(filepath, 'rb') as f:
        label_chs = np.load(f)
        value_chs = np.load(f)
        last_samp = np.load(f)
        samp_freq = np.load(f) 
    
    return label_chs, value_chs, last_samp, samp_freq


def _process_windowHVs(window_chs, 
                       window_size, 
                       n, 
                       feature_set, 
                       memory, 
                       feature_min = None,
                       feature_max = None,
                       levels = None,
                       d = 0, 
                       fs = 256):
    """
    Processes a window of samples of multiple channels and returns the window hypervector depending on the chosen feature set.

    ### Parameters:
        window_chs : np.ndarray of array
            array of samples in input window in an array of multiple channels
        window_size : int
            number of samples in input window
        n : int
            dimension of hypervector
        feature_set : int
            1 = LBP only;
            2 = Spectral power only;
            3 = Line length, mean amplitude, LBP;
            4 = Line length & spectral power
        memory : tuple of np.ndarray
            Contains hypervector memory for chosen feature set
        d : int, optional
            For feature sets with LBP; defines number of bits of LBP
    """

    num_chs = len(window_chs)
    arr_sampleHVs = np.zeros((window_size, n), dtype=int)

    match feature_set:
            
        case 1: # LBP only
            memory_chs, memory_LBP = memory

            for i in range(d, (window_size + d)): # loop per sample
                sum_hv = np.zeros((num_chs, n), dtype=int)
                for j in range(num_chs): # loop per channel
                    value_LBP = hdc.compute_LBP(window_chs[j][i-d:i+1])
                    hv_LBP = memory_LBP[value_LBP]
                    sum_hv[j] = hdc.bind(hv_LBP, memory_chs[j])

                arr_sampleHVs[i-d] = hdc.bundle(sum_hv, num_chs)

            return hdc.bundle(arr_sampleHVs, window_size)
        
        
        case 2: # Spectral Power only
            memory_chs, memory_spi, memory_spv = memory
            sum_chs = np.zeros((num_chs, n), dtype=int)
            for c in range(num_chs):

                value_bands = hdc.compute_bandPower(window=window_chs[c], fs=fs, ws=window_size)
                sum_bands = np.zeros((len(value_bands), n), dtype=int)

                for b in range(len(value_bands)):
                    hv_band_id = memory_spi[b]
                    hv_band_val = hdc.extract_linearMemory(memory=memory_spv, value=value_bands[b], min=feature_min[b], max=feature_max[b], levels = 64)
                    sum_bands[b] = hdc.bind(hv_band_id, hv_band_val)
                
                sum_chs[c] = hdc.bind(memory_chs[c], hdc.bundle(sum_bands, len(sum_bands)))
                
            return hdc.bundle(sum_chs, num_chs)
        
        case default:
            return None


def train_file(n, window_size, window_step, feature_set, d, data, memory, levels, label_hv, filename):

    # Parse data
    name_chs, value_chs, last_samp, samp_freq = data
    
    allwindows_chs = [] # array of all sliced windows in all channels for multiprocessing

    # Divide value_chs into all windows depending on feature set
    match feature_set:
        case 1 | 3: # LBP only OR mean amplitude, line length and LBP
            for i in range(last_samp+1):
                if (i + 1) % window_step == d and i+d >= window_size + d: # computing last index of window
                    window_chs = value_chs[:, i + 1 - (window_size+d): i + 1] # get window of channels
                    allwindows_chs.append(window_chs)
        case 2 | 4: # Spectral power only OR Line length and spectral power
            for i in list(range(window_size - 1, last_samp + 1, window_step)):
                window_chs = value_chs[:, (i + 1 - window_size): i + 1] # get window of channels
                allwindows_chs.append(window_chs)

                if feature_set == 2:
                    with open("minmax_sp.npy", 'rb') as f:
                        min_patients = np.load(f)
                        max_patients = np.load(f)
                    feature_min = min_patients[int(filename[3:5]) - 1]
                    feature_max = max_patients[int(filename[3:5]) - 1]

    # Use multiprocessing library for processing window HVs in a window of channels
    with Pool(processes=8) as p, tqdm(total=len(allwindows_chs), desc=filename, leave=False) as pbar:
        for result in p.imap(partial(_process_windowHVs, 
                                     window_size=window_size,
                                     n=n,
                                     feature_set=feature_set,
                                     memory=memory,
                                     feature_min=feature_min,
                                     feature_max=feature_max,
                                     levels=levels,
                                     d=d,
                                     fs=int(samp_freq)), 
                            allwindows_chs, chunksize=1):
            pbar.update()
            pbar.refresh()
            label_hv = hdc.bundle([result, label_hv], 2)


    return label_hv


def train_leave_one_out(n, window_size, window_step, fs, feature_set, d, memory, levels, label, list_patients):

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
                    data = name_chs, value_chs, last_samp, fs

                    label_hv = train_file(n, window_size, window_step, feature_set, d, data, memory, levels, label_hv, file_inc)
                    pbar_all.write(f"Current label hv: {label_hv}")

            
            if label == "seizures":
                directory = f"training-data/{patient}/s_set{feature_set}_{file_exc[:-4]}.npy"
            elif label == "non-seizures":
                directory = f"training-data/{patient}/ns_set{feature_set}_{file_exc[:-4]}.npy"
            with open(directory, 'wb') as f:
                np.save(f, label_hv)


def test(test_filepath, n, window_size, window_step, fs, feature_set, d, memory, levels, seizure_filepath, non_seizure_filepath):
    _, _, patient, patient_file = test_filepath.split("/")
    name_chs, value_chs, last_samp, samp_freq = extract_npy(test_filepath)
    num_chs = len(value_chs)

    with open(seizure_filepath, 'rb') as f:
        seizure_hv = np.load(f)

    with open(non_seizure_filepath, 'rb') as f:
        non_seizure_hv = np.load(f)
    
    allwindows_chs = [] # array of all sliced windows in all channels for multiprocessing

    # Divide value_chs into all windows depending on feature set
    match feature_set:
        case 1 | 3: # LBP only OR mean amplitude, line length and LBP
            for i in range(last_samp+1):
                if (i + 1) % window_step == d and i+d >= window_size + d: # computing last index of window
                    window_chs = value_chs[:, i + 1 - (window_size+d): i + 1] # get window of channels
                    allwindows_chs.append(window_chs)
        case 2 | 4: # Spectral power only OR Line length and spectral power
            for i in list(range(window_size - 1, last_samp + 1, window_step)):
                window_chs = value_chs[:, (i + 1 - window_size): i + 1] # get window of channels
                allwindows_chs.append(window_chs)

                if feature_set == 2:
                    with open("minmax_sp.npy", 'rb') as f:
                        min_patients = np.load(f)
                        max_patients = np.load(f)
                    feature_min = min_patients[int(patient_file[3:5]) - 1]
                    feature_max = max_patients[int(patient_file[3:5]) - 1]

    num_seiz = 0
    num_non_seiz = 0
    # Use multiprocessing library for processing window HVs in a window of channels
    with Pool(processes=8) as p, tqdm(total=len(allwindows_chs), desc=patient_file, leave=False) as pbar:
        for result in p.imap(partial(_process_windowHVs, 
                                     window_size=window_size,
                                     n=n,
                                     feature_set=feature_set,
                                     memory=memory,
                                     feature_min=feature_min,
                                     feature_max=feature_max,
                                     levels=levels,
                                     d=d,
                                     fs=int(samp_freq)), 
                            allwindows_chs, chunksize=1):
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


def compute_featureMinMax(window_size, window_step, feature_set):
    """
    Computes the minimum and maximum values of each patient in ".../chbmit-eeg-processed".
    """

    
    log_min = []
    log_max = []
    pbar_patient = tqdm(os.listdir("chbmit-eeg-processed/non-seizures"), 
                        leave=False, 
                        total=len(os.listdir("chbmit-eeg-processed/non-seizures")))
    
    for patient in pbar_patient:
        pbar_patient.set_description(patient)

        if feature_set == 2:
            feature_min = [10000] * 6
            feature_max = [-10000] * 6
        else:
            feature_min = 10000
            feature_max = -10000

        for label in ["chbmit-eeg-processed/non-seizures", "chbmit-eeg-processed/seizures"]:
            for file in os.listdir(label + "/" +  patient):
                name_chs, value_chs, last_samp, samp_freq = extract_npy(label + "/" + patient + "/" + file)

                list_windows = list(range(window_size - 1, last_samp + 1, window_step))
                allwindows_chs = np.empty((0, 17, window_size))

                # Divide value_chs into all windows depending on feature set
                match feature_set:
                    case 1: # LBP
                        return None # No need to compute min max for LBP
                    case 2: # Spectral power only
                        for i in list_windows:
                            window_chs = value_chs[:, (i + 1 - window_size): i + 1] # get window of channels
                            allwindows_chs = np.append(allwindows_chs, np.array([window_chs]), axis = 0)

                        feature_file = "minmax_sp.npy"
                        
                        with Pool(processes=8) as p, tqdm(total=len(allwindows_chs)*len(name_chs), desc=file, leave=False) as pbar:
                            for c in range(len(name_chs)):
                                for result in p.imap(partial(hdc.compute_bandPower, 
                                                            fs = int(samp_freq),
                                                            ws=int(window_size)), 
                                                    allwindows_chs[:,c,:], chunksize=1):
                                    pbar.update()
                                    pbar.refresh()
                                    for i in range(len(result)):
                                        if result[i] < feature_min[i]:
                                            feature_min[i] = result[i]
                                        if result[i] > feature_max[i]:
                                            feature_max[i] = result[i]

                    case 3: # Mean amplitude only!!
                        for i in list_windows:
                            window_chs = value_chs[:, (i + 1 - window_size): i + 1] # get window of channels
                            allwindows_chs = np.append(allwindows_chs, np.array([window_chs]), axis = 0)

                        feature_file = "minmax_ma.npy"

                        with Pool(processes=8) as p, tqdm(total=len(allwindows_chs)*len(name_chs), desc=file, leave=False) as pbar:
                            for c in range(len(name_chs)):
                                for result in p.imap(partial(hdc.compute_meanAmp), 
                                                    allwindows_chs[:,c,:], chunksize=1):
                                    pbar.update()
                                    pbar.refresh()
                                    
                                    if result < feature_min:
                                        feature_min = result
                                    if result > feature_max:
                                        feature_max = result

                    case 4: # Line length
                        for i in list_windows:
                            window_chs = value_chs[:, (i + 1 - window_size): i + 1] # get window of channels
                            allwindows_chs = np.append(allwindows_chs, np.array([window_chs]), axis = 0)

                        feature_file = "minmax_ll.npy"

                        with Pool(processes=8) as p, tqdm(total=len(allwindows_chs)*len(name_chs), desc=file, leave=False) as pbar:
                            for c in range(len(name_chs)):
                                for result in p.imap(partial(hdc.compute_lineLength), 
                                                    allwindows_chs[:,c,:], chunksize=1):
                                    pbar.update()
                                    pbar.refresh()
                                    
                                    if result < feature_min:
                                        feature_min = result
                                    if result > feature_max:
                                        feature_max = result

            
        pbar_patient.write(f"Patient {patient} feature min: {feature_min}\nPatient {patient} feature max: {feature_max}")
        log_min.append(feature_min)
        log_max.append(feature_max)

    with open(feature_file, 'wb') as f:
        np.save(f, log_min)
        np.save(f, log_max)

    with open(feature_file[:-3] + ".txt", 'w') as f:
        f.write(str(log_min) + "\n" + str(log_max))

                    



if __name__ == "__main__":
    
    # parameters
    n = 2048 # dimension of HV
    window_size = 256 # (1.0 seconds)
    window_step = 128 # 0.5 seconds
    fs = 256
    d = 6 # LBP bit size
    num_chs = 17 # constant
    levels = 64

    ###################################################################
    # ITEM MEMORY


    # create_channel_memory(num_chs=num_chs)

    # Spectral power
    # create_feature_memory(feature_set=2, d = 6, levels = 64)

    ###################################################################
    # Training Main

    # list_patients = ["chb01"]

    # train_leave_one_out(n = n,
    #                     window_size = window_size,
    #                     window_step = window_step,
    #                     feature_set = feature_set,
    #                     d = d,
    #                     memory= [get_memory(0), get_memory(1)], 
    #                     label="non-seizures", 
    #                     list_patients=list_patients)
    
    # Spectral power only
    # for label in ["non-seizures", "seizures"]:
    #     train_leave_one_out(n = n,
    #                         window_size = window_size,
    #                         window_step = window_step,
    #                         fs=fs,
    #                         feature_set = 2,
    #                         d = 0,
    #                         memory= [get_memory(0)] + get_memory(2), 
    #                         levels=levels,
    #                         label=label, 
    #                         list_patients=list_patients)

    ###################################################################
    # Testing Main

    test_list = [
        ("chb01/chb01_03_0.npy", "chb01/chb01_03.npy", "chb01/s_set2_chb01_03_0.npy", "chb01/ns_set2_chb01_03.npy"),
        ("chb01/chb01_04_0.npy", "chb01/chb01_04.npy", "chb01/s_set2_chb01_04_0.npy", "chb01/ns_set2_chb01_04.npy"),
        ("chb01/chb01_15_0.npy", "chb01/chb01_15.npy", "chb01/s_set2_chb01_15_0.npy", "chb01/ns_set2_chb01_15.npy"),
        ("chb01/chb01_16_0.npy", "chb01/chb01_16.npy", "chb01/s_set2_chb01_16_0.npy", "chb01/ns_set2_chb01_16.npy"),
        ("chb01/chb01_18_0.npy", "chb01/chb01_18.npy", "chb01/s_set2_chb01_18_0.npy", "chb01/ns_set2_chb01_18.npy"),
        ("chb01/chb01_21_0.npy", "chb01/chb01_21.npy", "chb01/s_set2_chb01_21_0.npy", "chb01/ns_set2_chb01_21.npy"),
        ("chb01/chb01_26_0.npy", "chb01/chb01_26.npy", "chb01/s_set2_chb01_26_0.npy", "chb01/ns_set2_chb01_26.npy")
    ]

    for set in test_list:
        num_seiz, num_non_seiz = test("chbmit-eeg-processed/seizures/"+set[0], 
            n=n,
            window_size=window_size,
            window_step=window_step,
            fs=fs,
            feature_set=2,
            d=d,
            memory=[get_memory(0)] + get_memory(2),
            levels=levels,
            seizure_filepath=str("training-data/"+set[2]),
            non_seizure_filepath=str("training-data/"+set[3]))

        num_seiz, num_non_seiz = test("chbmit-eeg-processed/non-seizures/"+set[1], 
            n=n,
            window_size=window_size,
            window_step=window_step,
            fs=fs,
            feature_set=2,
            d=d,
            memory=[get_memory(0)] + get_memory(2),
            levels=levels,
            seizure_filepath=str("training-data/"+set[2]),
            non_seizure_filepath=str("training-data/"+set[3]))

    ###################################################################
        

    # compute_featureMinMax(window_size=window_size, window_step=window_step, feature_set=2)
