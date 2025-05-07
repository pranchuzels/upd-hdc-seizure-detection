import os, time, re
import numpy as np
import hdc_methods as hdc
from textwrap import dedent
from tqdm import tqdm
from multiprocessing import Pool
from functools import partial

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
    folderin = "preds_hdc/nonpost/"
    tolerance = 3
    for file in os.listdir(folderin):
        folderout = "preds_hdc/postproc/"
        filepath = folderin + file
        file_arr = np.loadtxt(filepath)
        if len(file) > 21:
            folderout += "seizures/"
        else:
            folderout += "nonseizures/"
        newfile_arr = post_processing_window(file_arr, tolerance)
        np.savetxt(folderout+file,newfile_arr)
