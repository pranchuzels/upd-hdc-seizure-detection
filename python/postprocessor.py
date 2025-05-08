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

def new_post_processing_window(arr, tolerance: int):
    # assuming 0.5 seconds per prediction
    new_preds = np.array([])
    wind = tolerance * 2 + 1
    if len(arr) < wind:
        return new_preds
    else:
        for i in range(0,len(arr)-wind):
            window = arr[i:i+11]
            num_zeros = (window == -1).sum()
            num_ones = (window == 1).sum()
            if(num_zeros > num_ones):
                new_preds = np.append(new_preds,[-1])
            elif(num_zeros < num_ones):
                new_preds = np.append(new_preds,[1])
    return new_preds
                

if __name__ == "__main__":
    tolerance = 5 # in seconds
    for sub in ["seizures","non-seizures"]:
        folderin = f"nonpost/{sub}/"
        for file in os.listdir(folderin):
            folderout = f"post/{sub}/"
            filepath = folderin + file
            file_arr = np.loadtxt(filepath)
            newfile_arr = new_post_processing_window(file_arr, tolerance)
            np.savetxt(folderout+file,newfile_arr)
