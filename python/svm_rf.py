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

def post_processing_window(arr, tolerance: int):
    for i in range(len(arr)):
        if i - tolerance < 0 or i + tolerance >= len(arr):
            continue
        else:
            arr1 = np.array(arr[i-tolerance:i])
            arr2 = np.array(arr[i+1:i+tolerance+1])
            # print(f"{arr1} - {arr[i]} - {arr2}")
            if np.array_equal(arr1, arr2):
                # print("changed")
                arr[i] = arr[i-tolerance]
    return arr

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
    testing_patients = ["chb"+str(x).zfill(2) for x in range(2, 1+1)]
    training_features = [1,2,3,4]
    feature_array = np.array([])
    label_array = np.array([])
    feature_array_test = np.array([])
    label_array_test = np.array([])
    use_post_processing = False
    tolerance = 5

    # TRAINING PHASE

    log_time = datetime.today().strftime('%Y-%m-%d %H:%M:%S')
    with open("svm_train_log.txt", 'a') as log:
            log.write(dedent(
                f"""
                ---
                Test Begin {log_time}
                ---
                #1 - LBP
                #2 - Band Power
                #3 - LBP + LL + MA
                #4 - LL + SP
                Postprocessing is set to {use_post_processing}
                """
            ))
    # b_filt, a_filt = scipy.signal.iirfilter(4, Wn=45, fs=fs, btype="low", ftype="butter")
    # h_filt = scipy.signal.firwin(5, 45, fs=fs)


    for feature in training_features:
        with open("svm_train_log.txt", 'a') as log:
                log.write(dedent(
                    f"""
                    Feature #{feature}
                    """
            ))
        for patient in training_patients:
            label_exc = "non-seizures"
            path_patient = f"chbmit-eeg-processed/{label_exc}/" + patient
            files_patient = os.listdir(path_patient)
            files = len(files_patient)
            sens_tot_tot = 0
            spec_tot_tot = 0
            avg_sens = 0
            avg_spec = 0
            avg_sens_0 = 0
            avg_spec_0 = 0
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
                    counter = 0
                    for file_inc in files_patient:
                        counter += 1
                        if file_inc in file_exc:
                            continue
                        else:
                            name_chs, value_chs, last_samp, samp_freq = extract_npy(str(path_patient + "/"+ file_inc))
                            
                            samples = len(value_chs[0])
                            for j in range(0, samples, window_step):
                                # line length and mean amplitude
                                # i = scipy.signal.filtfilt(b_filt, a_filt, i)
                                # i = scipy.signal.upfirdn(h_filt, i)
                                # print(f"Working... {counter} of {samples} - {file_inc}")
                                feat_temp = np.array([])
                                # print(f"{j} out of {samples}")
                                for m in value_chs:
                                    if j + window_size >= len(m):
                                        break
                                    else:
                                        i = m[j:j+window_size]
                                    if feature == 1:
                                        lbp = np.histogram(hdc.compute_optimizedLBP(i,6),bins=np.array(range(0,65)))[0]
                                        feat_temp = np.append(feat_temp, lbp)
                                    elif feature == 2:
                                        sp = np.array(hdc.compute_bandPower(i, fs, window_size))
                                        feat_temp = np.append(feat_temp, sp)
                                    elif feature == 3:
                                        lbp = np.histogram(hdc.compute_optimizedLBP(i,6),bins=np.array(range(0,65)))[0]
                                        feat_temp = np.append(feat_temp, lbp)
                                        ll_ma = np.array([hdc.compute_lineLength(i),hdc.compute_meanAmp(i)])
                                        feat_temp = np.append(feat_temp, ll_ma)
                                    elif feature == 4:
                                        sp = np.array(hdc.compute_bandPower(i, fs, window_size))
                                        feat_temp = np.append(feat_temp, sp)
                                        ll = np.array([hdc.compute_lineLength(i)])
                                        feat_temp = np.append(feat_temp, ll)
                                if len(feat_temp) == 0:
                                    continue
                                else:
                                    feature_array = np.append(feature_array, feat_temp)
                                    if label == "non-seizures":
                                        label_array = np.append(label_array, [-1])
                                        
                                    else:
                                        label_array = np.append(label_array, [1])
                                    # print(f"feat array - {len(feature_array)/(64*17)}, label_array - {len(label_array)}, loop - {counter}")
                        print(f"file {counter} out of {len(files_patient)}")

                
                if feature == 1:
                    feature_array = feature_array.reshape(-1,64*17)
                if feature == 2:
                    feature_array = feature_array.reshape(-1,6*17)
                if feature == 3:
                    feature_array = feature_array.reshape(-1,66*17)
                if feature == 4:
                    feature_array = feature_array.reshape(-1,7*17)
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
                    samples = len(value_chs[0])
                    for j in range(0, samples, window_step):
                        # line length and mean amplitude
                        feat_temp_test = np.array([])
                        for m in value_chs:
                            if j + window_size >= len(m):
                                break
                            else:
                                i = m[j:j+window_size]
                            if feature == 1:
                                lbp = np.histogram(hdc.compute_optimizedLBP(i,6),bins=np.array(range(0,65)))[0]
                                feat_temp_test = np.append(feat_temp_test, lbp)
                            elif feature == 2:
                                sp = np.array(hdc.compute_bandPower(i, fs, window_size))
                                feat_temp_test = np.append(feat_temp_test, sp)
                            elif feature == 3:
                                lbp = np.histogram(hdc.compute_optimizedLBP(i,6),bins=np.array(range(0,65)))[0]
                                feat_temp_test = np.append(feat_temp_test, lbp)
                                ll_ma = np.array([hdc.compute_lineLength(i),hdc.compute_meanAmp(i)])
                                feat_temp_test = np.append(feat_temp_test, ll_ma)
                            elif feature == 4:
                                sp = np.array(hdc.compute_bandPower(i, fs, window_size))
                                feat_temp_test = np.append(feat_temp_test, sp)
                                ll = np.array([hdc.compute_lineLength(i)])
                                feat_temp_test = np.append(feat_temp_test, ll)
                        if len(feat_temp_test) == 0:
                            continue
                        else:
                            feature_array_test = np.append(feature_array_test, feat_temp_test)
                            if label_exc == "non-seizures":
                                label_array_test = np.append(label_array_test, [-1])
                                
                            else:
                                label_array_test = np.append(label_array_test, [1])
                print(f"Completed testing {file_exc}")
                print(len(feature_array_test))
                if feature == 1:
                    feature_array_test = feature_array_test.reshape(-1,64*17)
                if feature == 2:
                    feature_array_test = feature_array_test.reshape(-1,6*17)
                if feature == 3:
                    feature_array_test = feature_array_test.reshape(-1,66*17)
                if feature == 4:
                    feature_array_test = feature_array_test.reshape(-1,7*17)
                
                

                print(f"For feature #{feature} and for file {file_exc}")
                
                sens = 0
                spec = 0
                sens_tot = 0
                spec_tot = 0
                test_out = clf.predict(feature_array_test)
                if use_post_processing:
                    print(f"Post-processing enabled")
                    test_out = post_processing_window(test_out, tolerance)
                    pred_filename = f"predictions/postprocessed/Feature{feature}_{file_exc[0]}.txt"
                else:
                    pred_filename = f"predictions/nonpost/Feature{feature}_{file_exc[0]}.txt"
                np.savetxt(pred_filename, test_out)
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
                avg_sens += sens
                sens_tot_tot += sens_tot
                print(f"Non-seizures: {spec} out of {spec_tot}")
                avg_spec += spec
                spec_tot_tot += spec_tot
            avg_sens_0 = avg_sens/sens_tot_tot
            avg_spec_0 = avg_spec/spec_tot_tot
            print(f"Sensitivity of {patient}: {avg_sens_0}")
            print(f"Specificity of {patient}: {avg_spec_0}")
            with open("svm_train_log.txt", 'a') as log:
                log.write(dedent(
                    f"""
                    {patient}
                    Sensitivity: {avg_sens_0} ({avg_sens} out of {sens_tot_tot})
                    Specificity: {avg_spec_0} ({avg_spec} out of {spec_tot_tot})
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
