import os, time, re
import numpy as np
import hdc_methods as hdc
from textwrap import dedent
from tqdm import tqdm
from multiprocessing import Pool
from functools import partial

if __name__ == "__main__":
    with open("testing_log.txt", 'a') as log:
        log.write(dedent("Test Start"))
    for patient in ["chb"+str(x).zfill(2) for x in range(1, 24+1)]:
        for feat in ["feature2","feature4"]:
            sens = 0
            spec = 0
            sens_tot = 0
            spec_tot = 0
            for type in ["seizures", "non-seizures"]:
                folderin = f"post/{type}/"
                for file in os.listdir(folderin):
                    curpatient, feature, file_id, _ = file.split("_")
                    if feature != feat or curpatient != patient:
                        continue
                    testarr = np.loadtxt(folderin+file, ndmin=1)
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
            with open("testing_log_hdc_post.txt", 'a') as log:
                log.write(dedent(f"""
                    Sensitivity for {patient} {feat}: {sens} out of {sens_tot} - {(sens/sens_tot)*100}%
                    Specificity for {patient} {feat}: {spec} out of {spec_tot} - {(spec/spec_tot)*100}%
                """))
    with open("testing_log.txt", 'a') as log:
        log.write(dedent("Test End"))
