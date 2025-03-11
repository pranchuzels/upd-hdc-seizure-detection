import os, time, re
import numpy as np
import hdc_methods as hdc
from textwrap import dedent
from tqdm import tqdm
from multiprocessing import Pool
from functools import partial

# TODO:
# - Fix docstrings and type hints (tuple ndarray might not be working on py 3.8/9)
# - Remove unnecessary params and functions


def create_memory(n: int, mem_type: int, items: int = None) -> None:
    """
    Creates a .npy file in "training-data" subdirectory containing the memory of chosen type.

    ### Parameters:

        n : int
            Dimension of hypervector

        mem_type : int
                0 = Channel memory;
                1 = LBP;  
                2 = Spectral Power;  
                3 = Mean amplitude;  
                4 = Line length;  
                5 = Feature IDs

        items: int
            Number of items in memory.
            For LBP, this dictates the number of bits, i.e. 2**items = total number of patterns.
    """
    if mem_type == 0: # Channel memory
        memory_chs = hdc.generate_randommemory(n=n, p=0.5, d=items)
        with open("training-data/memory_channels.npy", 'wb') as f:
            np.save(f, memory_chs)
    elif mem_type == 1: # LBP
        memory_LBP = hdc.generate_randommemory(n=n, p=0.5, d=2**items)
        with open("training-data/memory_LBP.npy", 'wb') as f:
            np.save(f, memory_LBP)
    elif mem_type == 2: # Spectral Power
        memory_spi = hdc.generate_randommemory(n=n, p=0.5, d=items)
        memory_spv = hdc.generate_linearmemory(n=n, p=0.5, d=items)
        with open("training-data/memory_sp.npy", 'wb') as f:
            np.save(f, memory_spi)
            np.save(f, memory_spv)
    elif mem_type == 3: # Mean amplitude
        memory_ma = hdc.generate_linearmemory(n=n, p=0.5, d=items)
        with open("training-data/memory_ma.npy", 'wb') as f:
            np.save(f, memory_ma)
    elif mem_type == 4: # Line length
        memory_ll = hdc.generate_linearmemory(n=n, p=0.5, d=items)
        with open("training-data/memory_ll.npy", 'wb') as f:
            np.save(f, memory_ll)
    elif mem_type == 5: # Feature IDs
        memory_FID = hdc.generate_randommemory(n=n, p=0.5, d=4)
        with open("training-data/memory_FID.npy", 'wb') as f:
            np.save(f, memory_FID)
    

def get_memory(mem_type: int) -> np.ndarray:
    """
    Returns the memory as a numpy array from a .npy file of the chosen type.

    ### Parameters:
        mem_type : int
                0 = Channel memory;
                1 = LBP;  
                2 = Spectral Power;  
                3 = Mean amplitude;  
                4 = Line length;  
                5 = Feature IDs
    """
    if mem_type == 0: # Channels
        with open ("training-data/memory_channels.npy", 'rb') as f:
            memory_chs = np.load(f)
        return memory_chs
        
    elif mem_type == 1: # LBP only
        with open ("training-data/memory_LBP.npy", 'rb') as f:
            memory_LBP = np.load(f)
        return memory_LBP
        
    elif mem_type == 2: # Spectral Power only
        with open ("training-data/memory_sp.npy", 'rb') as f:
            memory_spi = np.load(f)
            memory_spv = np.load(f)
        return [memory_spi, memory_spv]
        
    elif mem_type == 3: # Mean amplitude
        with open ("training-data/memory_ma.npy", 'rb') as f:
            memory_ma = np.load(f)
        return memory_ma
        
    elif mem_type == 4: # Line length
        with open ("training-data/memory_ll.npy", 'rb') as f:
            memory_ll = np.load(f)
        return memory_ll
        
    elif mem_type == 5: # Feature IDs
        with open("training-data/memory_FID.npy", 'rb') as f:
            memory_FID = np.load(f)
        return memory_FID
        

def extract_npy(filepath: str):
    """
    Extracts and returns data of a patient file given a filepath.

    ### Parameters:
        filepath: str
            Filepath of patient file relative to current directory.
        
    ### Returns:
        label_chs: numpy array of strings
            Array of channel names in current patient file.

        value_chs: numpy array of array of floats
            Arrays of sample values inside an array of different channels in the patient file.

        last_samp: int
            Index of the last sample in all channel sample values.

        samp_freq: int
            Sampling frequency of the patient file.

    """
    with open(filepath, 'rb') as f:
        label_chs = np.load(f)
        value_chs = np.load(f)
        last_samp = np.load(f)
        samp_freq = np.load(f) 
    
    return label_chs, value_chs, int(last_samp), int(samp_freq)


def _process_windowHVs(window_chs: np.ndarray, 
                       window_size: int, 
                       n: int,
                       fs: int,
                       feature_set: int, 
                       memory, 
                       feature_min = None,
                       feature_max = None,
                       levels: int = None,
                       d: int = None):
    """
    Processes a window of samples of multiple channels and returns the window hypervector depending on the chosen feature set.

    ### Parameters:
        window_chs : numpy array
            Array of samples in input window in an array of multiple channels.

        window_size : int
            Number of samples in input window.

        n : int
            Dimension of hypervector.

        fs : int
            Sampling frequency of window samples.

        feature_set : int
            1 = LBP only;
            2 = Spectral power only;
            3 = Line length, mean amplitude, LBP;
            4 = Line length & spectral power

        memory : tuple of numpy arrays
            Contains all item memory required for chosen feature set.

        feature_min, feature_max: tuple of numpy arrays and/or floats
            Contains minimum and maximum values of chosen features for quantization in linear memory.
            Items can be a numpy array (for Spectral power bands) or float (line length, mean amplitude).

        levels : int, optional
            Number of items in linear item memories.

        d : int, optional
            For feature sets with LBP; defines number of bits of LBP
    """

    num_chs = len(window_chs)
            
    if feature_set == 1: # LBP only

        # Original method
        # memory_chs, memory_LBP = memory
        # sum_LBP = np.zeros((window_size, n), dtype=int)
        # for i in range(d, (window_size + d)): # loop per sample
        #     sum_hv = np.zeros((num_chs, n), dtype=int)
        #     for j in range(num_chs): # loop per channel
        #         value_LBP = hdc.compute_LBP(window_chs[j][i-d:i+1])
        #         hv_LBP = memory_LBP[value_LBP]
        #         sum_hv[j] = hdc.bind(hv_LBP, memory_chs[j])

        #     sum_LBP[i-d] = hdc.bundle(sum_hv)

        # return hdc.bundle(sum_LBP)
    

        # Optimized method
        memory_chs, memory_LBP = memory
        sum_LBP = np.zeros((window_size, n), dtype=int)
        LBP_chs = np.zeros((num_chs, window_size, n), dtype=int)
        LBP_vals = np.zeros((num_chs, window_size), dtype=int)
        for c in range(num_chs):
            LBP_vals[c] = hdc.compute_optimizedLBP(window_chs[c], d=d)

        for i in range(window_size): # loop per sample
            sample_binded = np.logical_xor(memory_LBP[LBP_vals[:, i]], memory_chs)
            sum_LBP[i] = hdc.bundle(sample_binded)

        return hdc.bundle(sum_LBP)
    
    
    elif feature_set == 2: # Spectral Power only
        memory_chs, memory_sp = memory
        memory_spi, memory_spv = memory_sp
        sum_chs = np.zeros((num_chs, n), dtype=int)
        for c in range(num_chs): # loop per channel

            value_bands = hdc.compute_bandPower(window=window_chs[c], fs=fs, ws=window_size)
            sum_bands = np.zeros((len(value_bands), n), dtype=int)

            for b in range(len(value_bands)): # loop per band
                hv_band_id = memory_spi[b]
                hv_band_val = hdc.extract_linearMemory(memory=memory_spv, value=value_bands[b], min=feature_min[b], max=feature_max[b], levels = 64)
                sum_bands[b] = hdc.bind(hv_band_id, hv_band_val)
            
            sum_chs[c] = hdc.bind(memory_chs[c], hdc.bundle(sum_bands))
            
        return hdc.bundle(sum_chs)
    
    elif feature_set == 3:
        memory_chs, memory_ll, memory_ma, memory_LBP, memory_feature = memory
        min_ll, min_ma = feature_min
        max_ll, max_ma = feature_max
        sum_winhv = np.zeros((3, n), dtype=int)
        sum_ll = np.zeros((num_chs, n), dtype=int)
        sum_ma = np.zeros((num_chs, n), dtype=int)
        sum_LBP = np.zeros((window_size, n), dtype=int)
        for c in range(num_chs): # loop per channel
            
            # compute for line length
            value_ll = hdc.compute_lineLength(window=window_chs[c])
            hv_ll = hdc.extract_linearMemory(memory=memory_ll, value=value_ll, min=min_ll, max=max_ll, levels=levels)
            sum_ll[c] = hdc.bind(hv_ll, memory_chs[c])

            # compute for mean amplitude
            value_ma = hdc.compute_meanAmp(window=window_chs[c])
            hv_ma = hdc.extract_linearMemory(memory=memory_ma, value=value_ma, min=min_ma, max=max_ma, levels=levels)
            sum_ma[c] = hdc.bind(hv_ma, memory_chs[c])

        sum_winhv[0] = hdc.bind(memory_feature[4-1], hdc.bundle(sum_ll))
        sum_winhv[1] = hdc.bind(memory_feature[3-1], hdc.bundle(sum_ma))

        for i in range(d, (window_size + d)): # loop per sample
            sum_hv = np.zeros((num_chs, n), dtype=int)
            for j in range(num_chs): # loop per channel
                value_LBP = hdc.compute_LBP(window_chs[j][i-d:i+1])
                hv_LBP = memory_LBP[value_LBP]
                sum_hv[j] = hdc.bind(hv_LBP, memory_chs[j])

            sum_LBP[i-d] = hdc.bundle(sum_hv)

        sum_winhv[2] = hdc.bind(memory_feature[1-1], hdc.bundle(sum_LBP))

        return hdc.bundle(sum_winhv)

    elif feature_set == 4:
        memory_chs, memory_sp, memory_ll, memory_feature = memory
        memory_spi, memory_spv = memory_sp
        min_sp, min_ll = feature_min
        max_sp, max_ll = feature_max
        sum_winhv = np.zeros((2, n), dtype=int)
        sum_ll = np.zeros((num_chs, n), dtype=int)
        sum_sp = np.zeros((num_chs, n), dtype=int)
        for c in range(num_chs): # loop per channel
            
            # compute for line length
            value_ll = hdc.compute_lineLength(window=window_chs[c])
            hv_ll = hdc.extract_linearMemory(memory=memory_ll, value=value_ll, min=min_ll, max=max_ll, levels=levels)
            sum_ll[c] = hdc.bind(hv_ll, memory_chs[c])

            # compute for spectral power HV
            value_bands = hdc.compute_bandPower(window=window_chs[c], fs=fs, ws=window_size)
            sum_bands = np.zeros((len(value_bands), n), dtype=int)

            for b in range(len(value_bands)):
                hv_band_id = memory_spi[b]
                hv_band_val = hdc.extract_linearMemory(memory=memory_spv, value=value_bands[b], min=min_sp[b], max=max_sp[b], levels=levels)
                sum_bands[b] = hdc.bind(hv_band_id, hv_band_val)

            sum_sp[c] = hdc.bind(memory_chs[c], hdc.bundle(sum_bands))

        sum_winhv[0] = hdc.bind(memory_feature[4-1], hdc.bundle(sum_ll))
        sum_winhv[1] = hdc.bind(memory_feature[2-1], hdc.bundle(sum_sp))

        return hdc.bundle(sum_winhv)


def train_file(n, window_size, window_step, feature_set, d, data, memory, label_hv, filename, levels = None):

    # Parse data
    name_chs, value_chs, last_samp, samp_freq = data
    
    allwindows_chs = [] # array of all sliced windows in all channels for multiprocessing

    # Divide value_chs into all windows depending on feature set
    if feature_set == 1 or feature_set == 3: # LBP only OR mean amplitude, line length and LBP
        for i in range(last_samp+1):
            if (i + 1) % window_step == d and i+d >= window_size + d: # computing last index of window
                window_chs = value_chs[:, i + 1 - (window_size+d): i + 1] # get window of channels
                allwindows_chs.append(window_chs)

            if feature_set == 3:
                with open("minmax_ll.npy", 'rb') as f:
                    min_ll = np.load(f)
                    max_ll = np.load(f)
                with open("minmax_ma.npy", 'rb') as f:
                    min_ma = np.load(f)
                    max_ma = np.load(f)
                feature_min = min_ll[int(filename[3:5]) - 1], min_ma[int(filename[3:5]) - 1]
                feature_max = max_ll[int(filename[3:5]) - 1], max_ma[int(filename[3:5]) - 1]
            else:
                feature_min = None
                feature_max = None

    elif feature_set == 2 or feature_set == 4: # Spectral power only OR Line length and spectral power
        for i in list(range(window_size - 1, last_samp + 1, window_step)):
            window_chs = value_chs[:, (i + 1 - window_size): i + 1] # get window of channels
            allwindows_chs.append(window_chs)

            with open("minmax_sp.npy", 'rb') as f:
                min_sp = np.load(f)
                max_sp = np.load(f)

            if feature_set == 2:
                feature_min = min_sp[int(filename[3:5]) - 1]
                feature_max = max_sp[int(filename[3:5]) - 1]
            else:
                with open("minmax_ll.npy", 'rb') as f:
                    min_ll = np.load(f)
                    max_ll = np.load(f)
                feature_min = min_sp[int(filename[3:5]) - 1], min_ll[int(filename[3:5]) - 1]
                feature_max = max_sp[int(filename[3:5]) - 1], max_ll[int(filename[3:5]) - 1]


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
            label_hv = hdc.bundle([result, label_hv])


    return label_hv


def train_leave_one_out(n, window_size, window_step, fs, feature_set, d, memory, label, list_patients, levels = None):

    log_start_text = f"""
    \n
    ==========================================================
    Starting training of patients: {list_patients}
    With feature set: {feature_set}
    Label : {label}
    Time start: {time.ctime()}
    Parameters:
        - n: {n}
        - window_size: {window_size}
        - window_step: {window_step}
        - fs: {fs}
        - d: {d}
        - levels: {levels}
    \n
    """

    with open("training-data/log.txt", 'a') as log:
        log.write(dedent(log_start_text))

    np.set_printoptions(edgeitems=15)
    pbar_all = tqdm(list_patients, desc= f"Training all patients' {label} with leave-one-out approach.", leave=False, total=len(list_patients))
    for patient in pbar_all:

        path_patient = f"chbmit-eeg-processed/{label}/" + patient
        files_patient = os.listdir(path_patient)

        with open("training-data/log.txt", 'a') as log:
            log.write(dedent(
                f"""\
                ----------------------------------------------------------
                Currently training patient {patient}
                Time start: {time.ctime()}
                """
            ))


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

                    label_hv = train_file(n, window_size, window_step, feature_set, d, data, memory, label_hv, file_inc, levels)
                    pbar_all.write(f"Current label hv: {label_hv}")

            
            if label == "seizures":
                directory = f"training-data/{patient}/s_set{feature_set}_{file_exc[:-4]}.npy"
            elif label == "non-seizures":
                directory = f"training-data/{patient}/ns_set{feature_set}_{file_exc[:-4]}.npy"
            with open(directory, 'wb') as f:
                np.save(f, label_hv)

            with open("training-data/log.txt", 'a') as log:
                log.write(dedent(
                    f""" \
                    Completed leave-one-out with {file_exc[:-4]} on {time.ctime()}
                    """
                ))

        with open("training-data/log.txt", 'a') as log:
            log.write(dedent(
                f""" \
                Finished training patient {patient}
                Time end: {time.ctime()}
                ----------------------------------------------------------
                """
            ))


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
    if feature_set == 1 or feature_set == 3: # LBP only OR mean amplitude, line length and LBP
        for i in range(last_samp+1):
            if (i + 1) % window_step == d and i+d >= window_size + d: # computing last index of window
                window_chs = value_chs[:, i + 1 - (window_size+d): i + 1] # get window of channels
                allwindows_chs.append(window_chs)

                if feature_set == 3:
                    with open("minmax_ll.npy", 'rb') as f:
                        min_ll = np.load(f)
                        max_ll = np.load(f)
                    with open("minmax_ma.npy", 'rb') as f:
                        min_ma = np.load(f)
                        max_ma = np.load(f)
                    feature_min = min_ll[int(patient_file[3:5]) - 1], min_ma[int(patient_file[3:5]) - 1]
                    feature_max = max_ll[int(patient_file[3:5]) - 1], max_ma[int(patient_file[3:5]) - 1]
                else:
                    feature_min = None
                    feature_max = None

    elif feature_set == 2 or feature_set == 4: # Spectral power only OR Line length and spectral power
        for i in list(range(window_size - 1, last_samp + 1, window_step)):
            window_chs = value_chs[:, (i + 1 - window_size): i + 1] # get window of channels
            allwindows_chs.append(window_chs)

            with open("minmax_sp.npy", 'rb') as f:
                    min_sp = np.load(f)
                    max_sp = np.load(f)

            if feature_set == 2:
                feature_min = min_sp[int(patient_file[3:5]) - 1]
                feature_max = max_sp[int(patient_file[3:5]) - 1]
            else:
                with open("minmax_ll.npy", 'rb') as f:
                    min_ll = np.load(f)
                    max_ll = np.load(f)
                feature_min = min_sp[int(patient_file[3:5]) - 1], min_ll[int(patient_file[3:5]) - 1]
                feature_max = max_sp[int(patient_file[3:5]) - 1], max_ll[int(patient_file[3:5]) - 1]

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
            sim_seizure = hdc.compute_similarity(result, seizure_hv)
            sim_non_seizure = hdc.compute_similarity(result, non_seizure_hv)

            if sim_seizure <= sim_non_seizure:
                num_seiz += 1
            else:
                num_non_seiz += 1

    print(f"No. of seizure windows: {num_seiz}, No. of non-seizure windows: {num_non_seiz}")

    file_split = re.split('_|\.', patient_file)
    if len(file_split) == 3:
        file_id = file_split[1]
    else:
        file_id = str(file_split[1]) + "_" + str(file_split[2])

    with open("testing_log.txt", 'a') as log:
        log.write(dedent(
            f"{file_id}, {num_seiz},  {num_non_seiz}\n"
        ))

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
                if feature_set == 1: # LBP
                    return None # No need to compute min max for LBP
                elif feature_set == 2: # Spectral power only
                    for i in list_windows:
                        window_chs = value_chs[:, (i + 1 - window_size): i + 1] # get window of channels
                        allwindows_chs = np.append(allwindows_chs, np.array([window_chs]), axis = 0)

                    feature_file = "minmax_sp.npy"
                    
                    with Pool(processes=8) as p, tqdm(total=len(allwindows_chs)*len(name_chs), desc=file, leave=False) as pbar:
                        for c in range(len(name_chs)):
                            for result in p.imap(partial(hdc.compute_bandPower, 
                                                        fs = samp_freq,
                                                        ws=int(window_size)), 
                                                allwindows_chs[:,c,:], chunksize=1):
                                pbar.update()
                                pbar.refresh()
                                for i in range(len(result)):
                                    if result[i] < feature_min[i]:
                                        feature_min[i] = result[i]
                                    if result[i] > feature_max[i]:
                                        feature_max[i] = result[i]

                elif feature_set == 3: # Mean amplitude only!!
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

                elif feature_set == 4: # Line length
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
    n = 10000 # dimension of HV
    window_size = 256 # 1.0 seconds
    window_step = 128 # 0.5 seconds
    fs = 256
    d = 6 # LBP bit size
    num_chs = 17 # constant
    levels = 64

    ###################################################################
    # ITEM MEMORY CREATION (comment out as needed)

    # create_memory(n=n, mem_type=0, items = num_chs) # channels
    # create_memory(n=n, mem_type=1, items = d) # LBP
    # create_memory(n=n, mem_type=2, items = levels) # spectral power
    # create_memory(n=n, mem_type=3, items = levels) # mean amplitude
    # create_memory(n=n, mem_type=4, items = levels) # line length
    # create_memory(n=n, mem_type=5) # feature IDs

    ###################################################################
    # MINIMUM MAXIMUM COMPUTATIONS 

    # compute_featureMinMax(window_size=window_size, window_step=window_step, feature_set=2)
    # compute_featureMinMax(window_size=window_size, window_step=window_step, feature_set=3)
    # compute_featureMinMax(window_size=window_size, window_step=window_step, feature_set=4)

    ###################################################################
    # TRAINING

    # Comment and/or edit parameters below for training
    # training_patients = ["chb"+str(x).zfill(2) for x in range(1, 24+1)]
    # training_features = [1, 2, 3, 4]
    # training_patients = ["chb01"]
    # training_features = [1]
    

    # for label in ["non-seizures", "seizures"]:
    #     # LBP only
    #     if 1 in training_features:
    #         train_leave_one_out(n = n,
    #                             window_size = window_size,
    #                             window_step = window_step,
    #                             fs=fs,
    #                             feature_set = 1,
    #                             d = d,
    #                             memory= (get_memory(0), get_memory(1)), 
    #                             label=label, 
    #                             list_patients=training_patients)
        
    #     # Spectral power only
    #     if 2 in training_features:
    #         train_leave_one_out(n = n,
    #                             window_size = window_size,
    #                             window_step = window_step,
    #                             fs=fs,
    #                             feature_set = 2,
    #                             d = 0,
    #                             memory= (get_memory(0), get_memory(2)), 
    #                             levels=levels,
    #                             label=label, 
    #                             list_patients=training_patients)

    #     # Line Length, mean amplitude, LBP
    #     if 3 in training_features:
    #         train_leave_one_out(n = n,
    #                             window_size = window_size,
    #                             window_step = window_step,
    #                             fs=fs,
    #                             feature_set = 3,
    #                             d = 6,
    #                             memory= (get_memory(0), get_memory(4), get_memory(3), get_memory(1), get_memory(5)), 
    #                             levels=levels,
    #                             label=label, 
    #                             list_patients=training_patients)
            
    #     # Line Length and spectral power
    #     if 4 in training_features:
    #         train_leave_one_out(n = n,
    #                             window_size = window_size,
    #                             window_step = window_step,
    #                             fs=fs,
    #                             feature_set = 4,
    #                             d = 0,
    #                             memory= (get_memory(0), get_memory(2), get_memory(4), get_memory(5)), 
    #                             levels=levels,
    #                             label=label, 
    #                             list_patients=training_patients)

    ###################################################################
    # TESTING

    # Comment and/or edit parameters below for testing
    testing_patients = ["chb"+str(x).zfill(2) for x in range(1, 1+1)]
    testing_features = [1]

    for set in testing_features:

        log_start_text = f"""
        \n
        ==========================================================
        ==========================================================
        Patient, {testing_patients}
        Feature set, {set}
        Time start, {time.ctime()}
        Parameters:
        n, {n}
        window_size, {window_size}
        window_step, {window_step}
        fs, {fs}
        d, {d}
        levels, {levels}
        \n
        """

        with open("testing_log.txt", 'a') as log:
            log.write(dedent(log_start_text))

        if set == 1:
            memory = [get_memory(0), get_memory(1)]
        elif set == 2:
            memory = [get_memory(0), get_memory(2)]
        elif set == 3:
            memory = [get_memory(0), get_memory(4), get_memory(3), get_memory(1), get_memory(5)]
        elif set == 4:
            memory = [get_memory(0), get_memory(2), get_memory(4), get_memory(5)]

        for patient in testing_patients:

            with open("testing_log.txt", 'a') as log:
                log.write(dedent(
                    f"""\
                    ----------------------------------------------------------
                    Patient, {patient}
                    Time start, {time.ctime()}
                    """
                ))
            
            for patient_file in sorted(os.listdir("chbmit-eeg-processed/seizures/"+patient)):
                num_seiz, num_non_seiz = test("chbmit-eeg-processed/seizures/"+patient+"/"+patient_file, 
                    n=n,
                    window_size=window_size,
                    window_step=window_step,
                    fs=fs,
                    feature_set=set,
                    d=d,
                    memory=memory,
                    levels=levels,
                    seizure_filepath=str("training-data/" + patient + "/s_" + "set" + str(set) + "_" + patient_file),
                    non_seizure_filepath=str("training-data/" + patient + "/ns_" + "set" + str(set) + "_" + patient_file[:-6] + ".npy"))

            for patient_file in sorted(os.listdir("chbmit-eeg-processed/non-seizures/"+patient)):
                num_seiz, num_non_seiz = test("chbmit-eeg-processed/non-seizures/"+patient+"/"+patient_file, 
                    n=n,
                    window_size=window_size,
                    window_step=window_step,
                    fs=fs,
                    feature_set=set,
                    d=d,
                    memory=memory,
                    levels=levels,
                    seizure_filepath=str("training-data/" + patient + "/s_" + "set" + str(set) + "_" + patient_file[:-4] + "_0.npy"),
                    non_seizure_filepath=str("training-data/" + patient + "/ns_" + "set" + str(set) + "_" + patient_file))


            with open("testing_log.txt", 'a') as log:
                log.write(dedent(
                    f"""\
                    Time end, {time.ctime()}
                    ----------------------------------------------------------
                    """
                ))
