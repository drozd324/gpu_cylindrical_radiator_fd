import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv("writeup/task3.csv")

col_names = df.columns

m = col_names[0]
block_sizes = col_names[2]
speedup_time_compute = col_names[7]
speedup_time_calc_averages = col_names[12]

matrix_sizes = list(set(df[m]))
matrix_sizes.sort()
print(matrix_sizes)

for mat_size in matrix_sizes:
    plt.clf()
    plt.figure()

    matrix_df = df[ df[m] == mat_size ]
    speedup_compute = matrix_df[speedup_time_compute]

    #print(list(speedup_compute)[0])
    #speedup_compute = speedup_compute / list(speedup_compute)[0]

    #speedup_avg = matrix_df[speedup_time_calc_averages]
    block = matrix_df[block_sizes]

    plt.semilogx(block, speedup_compute, label=f"compute")
    #plt.plot(block, speedup_avg, label=f"calc avg")

plt.xlabel("block size")
plt.ylabel("speedup compute")
plt.legend()
plt.title(f"m=n={mat_size}")
plt.savefig(f"./writeup/plot_m{mat_size}.png", dpi=300)
#plt.savefig(f"./writeup/plot.png", dpi=300)
