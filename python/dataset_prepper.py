import mne
import numpy as np
import random

log_text = ""
successes = 0
fails = 0

file_seizures_arr = []
constant_chs = [
    "FP1-F7",
    "F7-T7",
    "T7-P7",
    "P7-O1",
    "FP1-F3",
    "F3-C3",
    "C3-P3",
    "P3-O1",
    "FP2-F4",
    "F4-C4",
    "C4-P4",
    "P4-O2",
    "FP2-F8",
    "F8-T8",
    "P8-O2",
    "FZ-CZ",
    "CZ-PZ"
]

with open("chbmit-eeg/RECORDS-WITH-SEIZURES", 'r') as file_seizures:
    content = file_seizures.read()
    file_seizures_arr = content.splitlines()


for i in range(len(file_seizures_arr)):

    patient = file_seizures_arr[i].split("/")[0]
    patient_file = file_seizures_arr[i].split("/")[1]
    raw_edf = mne.io.read_raw_edf("chbmit-eeg/"+file_seizures_arr[i], include=constant_chs, verbose=False)
    label_chs = raw_edf.ch_names

    if len(label_chs) != 17:
        msg = "Skipped " + patient_file + " due to missing channels."
        print(msg)
        log_text += msg + "\n\n"
        fails += 1
    else:
        samp_freq = int(raw_edf.info["sfreq"]) # should always be 256Hz
        last_samp = raw_edf.last_samp
        value_chs = raw_edf.get_data()
        successes += 1

        with open("chbmit-eeg/" + patient + "/" + patient + "-summary.txt", 'r') as summary:
            content = summary.read()

            if "chb24" in patient_file:
                num_lines = 2
            else:
                num_lines = 4

            #extract text block of current file in summary.txt
            index_file = content.index(patient_file)
            file_data = content[index_file:].split("\n", num_lines)
            num_seizures = int(file_data[num_lines-1].split(":")[1])
            
            # update file_data with number of seizures
            file_data = content[index_file:].split("\n", num_lines + (num_seizures*2))

            #save tuples of start and end indexes of seizures occured in file
            index_seizures_arr = []
            length_seizures = 0
            for j in range(num_seizures):
                index_seizure_start = int(file_data[num_lines + (2*j)].split(":")[1].strip().split(" ")[0]) * samp_freq
                index_seizure_end = int(file_data[num_lines + ( (2*j) + 1)].split(":")[1].strip().split(" ")[0]) * samp_freq

                # Save seizure block to npy file
                with open("chbmit-eeg-processed\\seizures\\" + patient_file[:-4] + "_" + str(j) + ".npy", 'wb') as f:
                    np.save(f, label_chs)
                    np.save(f, value_chs[:, index_seizure_start:index_seizure_end + 1])
                    np.save(f, index_seizure_end - index_seizure_start)
                    np.save(f, samp_freq)

                index_seizures_arr.append((index_seizure_start, index_seizure_end))
                length_seizures += index_seizure_end - index_seizure_start + 1

            msg = "Extracted " + str(num_seizures) + " seizures in " + patient_file[:-4] + "."
            print(msg)
            log_text += msg + "\n"

            # Create indexes of seizure samples for exclude set
            index_exclude = set()
            for (start, end) in index_seizures_arr:
                start = 0 if start < 256 else start - 256
                end = last_samp if last_samp < end + (256*15) else end + (256*15)
                index_exclude.add(range(start, end + 1))

            # Randomly choose block with same length of seizure block
            while True:
                index_nonseiz_end = random.choice(list(set(range(last_samp + 1)) - index_exclude))
                index_nonseiz_start = index_nonseiz_end - length_seizures + 1
                if index_nonseiz_start >= 0 and index_nonseiz_start not in index_exclude:

                    with open("chbmit-eeg-processed\\non-seizures\\" + patient_file[:-4] + ".npy", 'wb') as f:
                        np.save(f, label_chs)
                        np.save(f, value_chs[:, index_nonseiz_start:index_nonseiz_end + 1])
                        np.save(f, index_nonseiz_end - index_nonseiz_start)
                        np.save(f, samp_freq)

                    msg = "Chose [" + str(index_nonseiz_start) + ":" + str(index_nonseiz_end)  + "] samples for non-seizure of " + patient_file[:-4] +"."
                    print(msg)
                    log_text += msg + "\n"
                    break
                else:
                    continue

        print("\n")
        log_text += "\n"

msg = "Processed " + str(successes) + " files. " + str(fails) + " files skipped."
log_text += msg + "\n"
print(msg)

with open("chbmit-eeg-processed/logs.txt", "w") as logs:
    logs.write(log_text)