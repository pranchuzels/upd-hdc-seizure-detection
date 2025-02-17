import os, re
import numpy as np
import hdc_methods as hdc


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
            
    

if __name__ == "__main__":
    patients = ["chb"+str(x).zfill(2) for x in range(1, 24+1)]
    set = 1
    for label in ["ns", "s"]:
        for patient in patients:
            print("====================================================\nTesting", patient)
            compute_labelSimilarities(patient, label, set)
            print("\n")