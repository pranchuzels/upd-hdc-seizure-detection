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
from matplotlib import pyplot as plt
from datetime import datetime
import scipy.signal

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
    training_patients = ["chb"+str(x).zfill(2) for x in range(1, 1+1)]
    testing_patients = ["chb"+str(x).zfill(2) for x in range(1, 1+1)]
    training_features = [1,2,3]
    feature_array = np.array([])
    label_array = np.array([])
    feature_array_test = np.array([])
    label_array_test = np.array([])

    # TRAINING PHASE

    # 1 - line length and mean amp
    # 2 - spectral power
    log_time = datetime.today().strftime('%Y-%m-%d %H:%M:%S')
    with open("svm_train_log.txt", 'a') as log:
            log.write(dedent(
                f"""
                ---
                Test Begin {log_time}
                ---
                #1 - Line Length + Mean Amplitude
                #2 - Band Power
                #3 - LBP
                """
            ))
    # b_filt, a_filt = scipy.signal.iirfilter(4, Wn=45, fs=fs, btype="low", ftype="butter")
    # h_filt = scipy.signal.firwin(5, 45, fs=fs)


    for feature in training_features:
        for patient in training_patients:
            label_exc = "non-seizures"
            path_patient = f"chbmit-eeg-processed/{label_exc}/" + patient
            files_patient = os.listdir(path_patient)
            files = len(files_patient)
            for exc in range(files):
                label_exc = "non-seizures"
                path_patient = f"chbmit-eeg-processed/{label_exc}/" + patient
                files_patient = os.listdir(path_patient)
                file_exc = np.array([])
                file_exc = np.append(file_exc, files_patient[exc])
                label_exc = "seizures"
                path_patient = f"chbmit-eeg-processed/{label_exc}/" + patient
                files_patient = os.listdir(path_patient)
                file_exc = np.append(file_exc, files_patient[exc])
                feature_array = np.array([])
                label_array = np.array([])
                feature_array_test = np.array([])
                label_array_test = np.array([])

                for label in ["seizures", "non-seizures"]:
                    path_patient = f"chbmit-eeg-processed/{label}/" + patient
                    files_patient = os.listdir(path_patient)
                    files = len(files_patient)
                    for file_inc in files_patient:
                        if file_inc in file_exc:
                            continue
                        else:
                            name_chs, value_chs, last_samp, samp_freq = extract_npy(str(path_patient + "/"+ file_inc))
                            for m in value_chs:
                                # line length and mean amplitude
                                # i = scipy.signal.filtfilt(b_filt, a_filt, i)
                                # i = scipy.signal.upfirdn(h_filt, i)
                                for j in range(0, int(len(m)), window_step):
                                    if j + window_size >= len(m):
                                        break
                                    else:
                                        i = m[j:j+window_size]
                                    if feature == 1:
                                        ll_ma = np.array([hdc.compute_lineLength(i),hdc.compute_meanAmp(i)])
                                        feature_array = np.append(feature_array, ll_ma)
                                    elif feature == 2:
                                        sp = np.array(hdc.compute_bandPower(i, fs, window_size))
                                        feature_array = np.append(feature_array, sp)
                                    elif feature == 3:
                                        lbp = np.histogram(hdc.compute_optimizedLBP(i,6),bins=np.array(range(0,65)))[0]
                                        feature_array = np.append(feature_array, lbp)
                                    if label == "non-seizures":
                                        label_array = np.append(label_array, [-1])
                                        
                                    else:
                                        label_array = np.append(label_array, [1])
                                    
                
                if feature == 1:
                    feature_array = feature_array.reshape(-1,2)
                if feature == 2:
                    feature_array = feature_array.reshape(-1,6)
                if feature == 3:
                    feature_array = feature_array.reshape(-1,64)
                clf = make_pipeline(StandardScaler(), SVC(gamma='auto'))
                clf.fit(feature_array, label_array)
                print(f"Completed training leave one out for {file_exc} with length of {len(feature_array)}")
                for file_exc_iter in range(len(file_exc)):
                    if file_exc_iter:
                        path_patient = f"chbmit-eeg-processed/seizures/" + patient
                        label_exc = "seizures"
                    else:
                        path_patient = f"chbmit-eeg-processed/non-seizures/" + patient
                        label_exc = "non-seizures"
                    file_exc_name = file_exc[file_exc_iter]
                    name_chs, value_chs, last_samp, samp_freq = extract_npy(str(path_patient + "/"+ file_exc_name))
                    for m in value_chs:
                        # line length and mean amplitude
                        for j in range(0, int(len(m)), window_step):
                            if j + window_size >= len(m):
                                break
                            else:
                                i = m[j:j+window_size]
                            if feature == 1:
                                ll_ma = np.array([hdc.compute_lineLength(i),hdc.compute_meanAmp(i)])
                                feature_array_test = np.append(feature_array_test, ll_ma)
                            if feature == 2:
                                sp = np.array(hdc.compute_bandPower(i, fs, window_size))
                                feature_array_test = np.append(feature_array_test, sp)
                            elif feature == 3:
                                lbp = np.histogram(hdc.compute_optimizedLBP(i,6),bins=np.array(range(0,65)))[0]
                                feature_array_test = np.append(feature_array_test, lbp)
                            if label_exc == "non-seizures":
                                label_array_test = np.append(label_array_test, [-1])
                            else:
                                label_array_test = np.append(label_array_test, [1])
                print(f"Completed testing {file_exc}")

                if feature == 1:
                    feature_array_test = feature_array_test.reshape(-1,2)
                if feature == 2:
                    feature_array_test = feature_array_test.reshape(-1,6)
                if feature == 3:
                    feature_array_test = feature_array_test.reshape(-1,64)
                
                

                print(f"For feature #{feature} and for file {file_exc}")
                sens = 0
                spec = 0
                sens_tot = 0
                spec_tot = 0
                test_out = clf.predict(feature_array_test)
                for l in range(len(test_out)):
                    t = test_out[l]
                    if label_array_test[l] == -1:
                        spec_tot += 1
                        if t == -1:
                            spec += 1
                    else:
                        sens_tot += 1
                        if t == 1:
                            sens += 1
                print(f"Seizures: {sens} out of {sens_tot}")
                print(f"Non-seizures: {spec} out of {spec_tot}")

                accuracy = clf.score(feature_array_test, label_array_test)
                print(accuracy)
                with open("svm_train_log.txt", 'a') as log:
                    log.write(dedent(
                        f"""
                        Feature #{feature} with {label_exc} file {file_exc} - {accuracy}
                        Seizures: {sens} out of {sens_tot}
                        Non-seizures: {spec} out of {spec_tot}
                        """
                ))
    log_time = datetime.today().strftime('%H:%M:%S')
    with open("svm_train_log.txt", 'a') as log:
            log.write(dedent(
                f"""
                ---
                Test End - {log_time}
                
                """
            ))
            
                            


    # for feature in training_features:
    #     print("Beginning training/testing for feature #"+str(feature))
    #     feature_array = np.array([])
    #     label_array = np.array([])
    #     feature_array_test = np.array([])
    #     label_array_test = np.array([])

    #     for label in ["non-seizures", "seizures"]:
    #         for patient in training_patients:
    #             path_patient = f"chbmit-eeg-processed/{label}/" + patient
    #             files_patient = os.listdir(path_patient)
    #             for file in files_patient:
    #                 name_chs, value_chs, last_samp, samp_freq = extract_npy(str(path_patient + "/"+ file))
    #                 for i in value_chs:
    #                     # line length and mean amplitude
    #                     if feature == 1:
    #                         ll_ma = np.array([hdc.compute_lineLength(i),hdc.compute_meanAmp(i)])
    #                         feature_array = np.append(feature_array, ll_ma)
    #                     elif feature == 2:
    #                         sp = np.array(hdc.compute_bandPower(i, fs, window_size))
    #                         feature_array = np.append(feature_array, sp)
    #                     if label == "non-seizures":
    #                         label_array = np.append(label_array, [0])
    #                     else:
    #                         label_array = np.append(label_array, [1])
    #             print("Completed training"+patient)
    #     if feature == 1:
    #         feature_array = feature_array.reshape(-1,2)
    #     if feature == 2:
    #         feature_array = feature_array.reshape(-1,6)
    #     clf = make_pipeline(StandardScaler(), SVC(gamma='auto'))
    #     clf.fit(feature_array, label_array)

    #     path_patient = f"chbmit-eeg-processed/{label_exc}/" + patient
    #     name_chs, value_chs, last_samp, samp_freq = extract_npy(str(path_patient + "/"+ file))

    #     print("Finished Training")

    #     # TESTING PHASE

    #     for label in ["non-seizures", "seizures"]:
    #         for patient in testing_patients:
    #             path_patient = f"chbmit-eeg-processed/{label}/" + patient
    #             files_patient = os.listdir(path_patient)
    #             for file in files_patient:
    #                 name_chs, value_chs, last_samp, samp_freq = extract_npy(str(path_patient + "/"+ file))
    #                 for i in value_chs:
    #                     # line length and mean amplitude
    #                     if feature == 1:
    #                         ll_ma = np.array([hdc.compute_lineLength(i),hdc.compute_meanAmp(i)])
    #                         feature_array_test = np.append(feature_array_test, ll_ma)
    #                     if feature == 2:
    #                         sp = np.array(hdc.compute_bandPower(i, fs, window_size))
    #                         feature_array_test = np.append(feature_array_test, sp)
    #                     if label == "non-seizures":
    #                         label_array_test = np.append(label_array_test, [0])
    #                     else:
    #                         label_array_test = np.append(label_array_test, [1])
    #             print("Completed testing"+patient)
    #     if feature == 1:
    #         feature_array_test = feature_array_test.reshape(-1,2)
    #     if feature == 2:
    #         feature_array_test = feature_array_test.reshape(-1,6)

    #     print("For feature #"+str(feature))
    #     accuracy = clf.score(feature_array_test, label_array_test)
    #     print(accuracy)

    #     with open("svm_train_log.txt", 'a') as log:
    #         log.write(dedent(
    #             f"""
    #             Feature #{feature} Accuracy: {accuracy}
    #             """
    #         ))
