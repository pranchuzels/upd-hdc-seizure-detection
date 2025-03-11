import os, re
import numpy as np
import hdc_methods as hdc
import main
import matplotlib.pyplot as plt

def compute_labelSimilarities(patient: str, label: str, set: int):
    set_str = "set" + str(set)
    if label == "ns":
        test_sim = sorted(list(filter(lambda filename: all(x in filename for x in [label, set_str]), os.listdir("training-data/" + patient))))
    else:
        test_sim = sorted(list(filter(lambda filename: filename[:6] == ("s_" + set_str), os.listdir("training-data/" + patient))))

    for file in test_sim:
        if label == "ns":
            with open("training-data/"+patient+"/"+file, 'rb') as f:
                file_hv = np.load(f)

            lf, sf, pf, idf, _ = re.split('_|\.', file)
            

            comp_file = "s_" + set_str + "_" + pf + "_" + idf + "_0.npy"
            with open("training-data/"+patient+"/"+comp_file, 'rb') as f:
                comp_hv = np.load(f)

        else:
            with open("training-data/"+patient+"/"+file, 'rb') as f:
                file_hv = np.load(f)

            lf, sf, pf, idf, scf, _ = re.split('_|\.', file)

            comp_file = "ns_" + set_str + "_" + pf + "_" + idf + ".npy"
            with open("training-data/"+patient+"/"+comp_file, 'rb') as f:
                comp_hv = np.load(f)

        print(f"Similarity of {file} & {comp_file}" ,hdc.compute_similarity(file_hv, comp_hv))
            
def plotFeatureValues(patient_ns_file: str, feature_set: int, window_size: int = 256, window_step: int = 128, d: int = 6):
    # ns_files = sorted(os.listdir("chbmit-eeg-processed/non-seizures/" + patient))
    # s_files = sorted(os.listdir("chbmit-eeg-processed/seizures/" + patient))
    patient = patient_ns_file.split("_")[0]

    name_chs, value_chs, last_samp, samp_freq = main.extract_npy("chbmit-eeg-processed/non-seizures/" + patient  + "/" + patient_ns_file)
    allwindows_chs = []
    for i in range(last_samp+1):
        if (i + 1) % window_step == d and i+d >= window_size + d: # computing last index of window
            window_chs = value_chs[:, i + 1 - (window_size+d): i + 1] # get window of channels
            allwindows_chs.append(window_chs)

    num_chs = len(name_chs)
    ns_LBP_vals = np.zeros((num_chs, window_size), dtype=int)
    for window_chs in allwindows_chs:
        for c in range(num_chs):
            ns_LBP_vals[c] = hdc.compute_optimizedLBP(window_chs[c], d=d)


    ns_lbp_count_ac = [0 for _ in range(2**d)]
    
    for c in range(num_chs):
        for pat in ns_LBP_vals[c]:
            ns_lbp_count_ac[pat] += 1

    s_lbp_count_ac = [0 for _ in range(2**d)]
    s_files = sorted(list(filter(lambda filename: patient_ns_file[:-4] in filename, os.listdir("chbmit-eeg-processed/seizures/" + patient))))
    for s_file in s_files:
        if feature_set == 1:

            name_chs, value_chs, last_samp, samp_freq = main.extract_npy("chbmit-eeg-processed/seizures/" + patient + "/" + s_file)
            allwindows_chs = []
            for i in range(last_samp+1):
                if (i + 1) % window_step == d and i+d >= window_size + d: # computing last index of window
                    window_chs = value_chs[:, i + 1 - (window_size+d): i + 1] # get window of channels
                    allwindows_chs.append(window_chs)

            
            num_chs = len(name_chs)
            s_LBP_vals = np.zeros((num_chs, window_size), dtype=int)
            for window_chs in allwindows_chs:
                for c in range(num_chs):
                    s_LBP_vals[c] = hdc.compute_optimizedLBP(window_chs[c], d=d)

            for c in range(num_chs):
                for pat in s_LBP_vals[c]:
                    s_lbp_count_ac[pat] += 1

            figure, axis = plt.subplots(1, 2)
            lbppats = [x for x in range(2**d)]
            axis[0].bar(lbppats, ns_lbp_count_ac)
            axis[0].set_title('NS count of' + patient_ns_file)
            axis[0].set_xlabel('LBP pattern')
            axis[0].set_ylabel('Occurences')
            
            axis[1].bar(lbppats, s_lbp_count_ac)
            axis[1].set_title('S count of ' + patient_ns_file)
            axis[1].set_xlabel('LBP pattern')
            axis[1].set_ylabel('Occurences')
            ymax = max(ns_lbp_count_ac + s_lbp_count_ac)
            axis[0].set_ylim([0, ymax])
            axis[1].set_ylim([0, ymax])
            plt.show(block=False)

    print("NS count:", ns_lbp_count_ac)
    print("S count:", s_lbp_count_ac)

            

            
            
if __name__ == "__main__":
    #####################################################
    # patients = ["chb"+str(x).zfill(2) for x in range(1, 24+1)]
    # set = 1
    # for label in ["ns", "s"]:
    #     for patient in patients:
    #         print("====================================================\nTesting", patient)
    #         compute_labelSimilarities(patient, label, set)
    #         print("\n")

    ######################################
    for file in sorted(os.listdir("chbmit-eeg-processed/non-seizures/chb02")):
        plotFeatureValues(file , 1)
    print("---Plot graph finish---")
    plt.show()