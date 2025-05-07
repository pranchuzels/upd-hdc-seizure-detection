import os, time, re
import numpy as np
import hdc_methods as hdc
from textwrap import dedent
from tqdm import tqdm
from multiprocessing import Pool
from functools import partial

if __name__ == "__main__":
    for feat in ["feature1","feature2","feature3","feature4"]:
        sens = 0
        spec = 0
        sens_tot = 0
        spec_tot = 0
        for type in ["seizures", "nonseizures"]:
            folderin = f"preds_hdc/postproc/{type}/"
            for file in os.listdir(folderin):
                if type == "seizures":
                    patient, feature, file_id, _ = file.split("_")
                else:
                    patient, feature, file_id = file.split("_")
                if feature != feat:
                    continue
                testarr = np.loadtxt(folderin+file)
                for val in testarr:
                    if type == "seizures":
                        testval = 1
                        sens_tot += 1
                        if val == testval:
                            sens += 1
                    else:
                        testval = -1
                        spec_tot += 1
                        if val == testval:
                            spec += 1
        print(f"Sensitivity for {feat}: {sens} out of {sens_tot} - {(sens/sens_tot)*100}%")
        print(f"Specificity for {feat}: {spec} out of {spec_tot} - {(spec/spec_tot)*100}%")
