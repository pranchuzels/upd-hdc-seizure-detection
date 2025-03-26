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

import tqdm

# Q12.3 signed fixed rep!! from uV values
num_int = 13 # including sign
num_frac = 3
with open("chbmit-eeg-processed/non-seizures/chb01/chb01_03.npy", 'rb') as f:
    label_chs = np.load(f)
    value_chs = np.load(f)
    last_samp = np.load(f)
    samp_freq = np.load(f)
    written_string = ""

    # num_values = 6  + 4 + (2*2) # LBP size + window size + window step * number of windows
    num_values = len(value_chs[0])
    num_channels = len(value_chs)
    for i in tqdm(range(num_values)):
        for j in range(num_channels):
            value = value_chs[j][i] * (10**6)
            
            scaled_value = value * (2**num_frac)
            bin_value = bin(abs(round(scaled_value)))

            if value >= 0:
                if len(bin_value) > num_int + num_frac + 2:
                    raise ValueError("Value too large for Q13.3 fixed rep")
                bin_value = bin_value.removeprefix("0b").rjust(num_int + num_frac, "0")
            else:
                if len(bin_value) > num_int + num_frac + 3:
                    raise ValueError("Value too large for Q13.3 fixed rep")
                bin_value = list(bin_value.removeprefix("0b").rjust(num_int + num_frac, "0"))
                for k in range(len(bin_value)):
                    if bin_value[k] == "0":
                        bin_value[k] = "1"
                    else:
                        bin_value[k] = "0"
                bin_value = "".join(bin_value)
                bin_value = bin(int(bin_value, 2) + 1)
                bin_value = bin_value.removeprefix("0b").rjust(num_int, "1")

            written_string += f"samples[{j}] = " + f"{num_int + num_frac}'b{bin_value}" + ";\n"
        written_string += "#3.90625\n"

with open("tb_encoder_sv_v2.txt", "w") as f:
    f.write(written_string) 