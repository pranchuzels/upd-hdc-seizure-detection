import numpy as np

# with open("memory_LBP.npy", 'rb') as f:
#     memory_LBP = np.load(f)

# with open("memory_LBP_sv.text", "w") as f:  
#     written_string = ""          
#     for i in range(len(memory_LBP)):
#         written_string += f"parameter LBP_{i} = "
#         written_string += "10000'h" + hex(int("".join(map(str, memory_LBP[i].tolist())), 2)).lstrip("0x")
#         written_string += ";\n"
#     f.write(written_string)



# with open("memory_channels.npy", 'rb') as f:
#     memory_channels = np.load(f)

# with open("memory_channels_sv.text", "w") as f:  
#     written_string = ""          
#     for i in range(len(memory_channels)):
#         written_string += f"parameter CH_{i} = "
#         written_string += "10000'h" + hex(int("".join(map(str, memory_channels[i].tolist())), 2)).lstrip("0x")
#         written_string += ";\n"
#     f.write(written_string)

with open("chbmit-eeg-processed/non-seizures/chb01/chb01_03.npy", 'rb') as f:
    label_chs = np.load(f)
    value_chs = np.load(f)
    last_samp = np.load(f)
    samp_freq = np.load(f)
    written_string = ""

    num_values = 6  + 4 + (2*2) # LBP size + window size + window step * number of windows
    num_channels = 4
    for i in range(num_values):
        for j in range(num_channels):
            written_string += f"samples[{j}] = " + str(value_chs[j][i] * (10**6)) + ";\n"
        written_string += "#3.90625\n"

with open("tb_encoder_sv.text", "w") as f:
    f.write(written_string) 