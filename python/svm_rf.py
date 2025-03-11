import os, time, re
import numpy as np
import hdc_methods as hdc
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from textwrap import dedent
from tqdm import tqdm
from multiprocessing import Pool
from functools import partial
from sklearn.svm import SVC

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

if __name__ == "__main__":
    # parameters
    n = 10000 # dimension of HV
    window_size = 256 # 1.0 seconds
    window_step = 128 # 0.5 seconds
    fs = 256
    d = 6 # LBP bit size
    num_chs = 17 # constant
    levels = 64
    training_patients = ["chb"+str(x).zfill(2) for x in range(1, 19+1)]
    testing_patients = ["chb"+str(x).zfill(2) for x in range(20, 24+1)]
    training_features = [1, 2]
    feature_array = np.array([])
    label_array = np.array([])
    feature_array_test = np.array([])
    label_array_test = np.array([])

    # TRAINING PHASE

    # 1 - line length and mean amp
    # 2 - spectral power
    with open("svm_train_log.txt", 'a') as log:
            log.write(dedent(
                f"""
                ---
                Test Begin
                ---
                """
            ))
    print("#1 - Line Length + Mean Amplitude")
    print("#2 - Band Power")
    for feature in training_features:
        print("Beginning training/testing for feature #"+str(feature))
        for label in ["non-seizures", "seizures"]:
            for patient in training_patients:
                path_patient = f"chbmit-eeg-processed/{label}/" + patient
                files_patient = os.listdir(path_patient)
                for file in files_patient:
                    name_chs, value_chs, last_samp, samp_freq = extract_npy(str(path_patient + "/"+ file))
                    for i in value_chs:
                        # line length and mean amplitude
                        if feature == 1:
                            ll_ma = np.array([hdc.compute_lineLength(i),hdc.compute_meanAmp(i)])
                            feature_array = np.append(feature_array, ll_ma)
                        if feature == 2:
                            sp = np.array(hdc.compute_bandPower(i, fs, window_size))
                            feature_array = np.append(feature_array, sp)
                        if label == "non-seizures":
                            label_array = np.append(label_array, [0])
                        else:
                            label_array = np.append(label_array, [1])
                print("Completed "+patient)
        if feature == 1:
            feature_array = feature_array.reshape(-1,2)
        if feature == 2:
            feature_array = feature_array.reshape(-1,6)
        clf = make_pipeline(StandardScaler(), SVC(gamma='auto'))
        clf.fit(feature_array, label_array)

        print("Finished Training")

        # TESTING PHASE

        for label in ["non-seizures", "seizures"]:
            for patient in testing_patients:
                path_patient = f"chbmit-eeg-processed/{label}/" + patient
                files_patient = os.listdir(path_patient)
                for file in files_patient:
                    name_chs, value_chs, last_samp, samp_freq = extract_npy(str(path_patient + "/"+ file))
                    for i in value_chs:
                        # line length and mean amplitude
                        if feature == 1:
                            ll_ma = np.array([hdc.compute_lineLength(i),hdc.compute_meanAmp(i)])
                            feature_array_test = np.append(feature_array_test, ll_ma)
                        if feature == 2:
                            sp = np.array(hdc.compute_bandPower(i, fs, window_size))
                            feature_array_test = np.append(feature_array_test, sp)
                        if label == "non-seizures":
                            label_array_test = np.append(label_array_test, [0])
                        else:
                            label_array_test = np.append(label_array_test, [1])
                print("Completed "+patient)
        if feature == 1:
            feature_array_test = feature_array_test.reshape(-1,2)
        if feature == 2:
            feature_array_test = feature_array_test.reshape(-1,6)

        print("For feature #"+str(feature))
        accuracy = clf.score(feature_array_test, label_array_test)
        print(accuracy)

        with open("svm_train_log.txt", 'a') as log:
            log.write(dedent(
                f"""
                Feature #{feature} Accuracy: {accuracy}
                """
            ))