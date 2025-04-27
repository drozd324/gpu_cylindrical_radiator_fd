import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

df_float = pd.read_csv("../float/writeup/task3.csv")
df_double = pd.read_csv("../double/writeup/task3.csv")

col_names = df_float.columns

m = col_names[0]
block_sizes = col_names[2]
speedup_time_compute = col_names[7]
speedup_time_calc_averages = col_names[12]

matrix_sizes = list(set(df_float[m]))
matrix_sizes.sort()

# plotting speedup for main compute

for mat_size in matrix_sizes:
	plt.clf()

	matrix_df_float = df_float[ df[m] == mat_size ]
	speedup_compute_float = matrix_df_float[speedup_time_compute]
	matrix_df_double = df_double[ df[m] == mat_size ]
    speedup_compute_double = matrix_df_double[speedup_time_compute]

	block = matrix_df_float[block_sizes]

	plt.semilogx(block, speedup_compute, label=f"compute")
	plt.semilogx(block, speedup_compute, label=f"compute")

	plt.xlabel("block size")
	plt.ylabel("speedup")
	plt.legend()
	plt.title(f"Speedup for main compute m=n={mat_size}")
	plt.savefig(f"./compute_plot_m{mat_size}.png", dpi=300)


# comparing reduce functions for avg temp
#
#df_old = pd.read_csv("writeup/task3_old_reduce.csv")
#
#for mat_size in matrix_sizes:
#	plt.clf()
#
#	matrix_df = df[ df[m] == mat_size ]
#	speedup_time_averages = matrix_df[speedup_time_calc_averages]
#
#	matrix_df_old = df_old[ df_old[m] == mat_size ]
#	speedup_time_averages_old = matrix_df_old[speedup_time_calc_averages]
#
#	block = matrix_df[block_sizes]
#
#	plt.semilogx(block, speedup_time_averages, label=f"new")
#	plt.semilogx(block, speedup_time_averages_old, label=f"old")
#
#	plt.xlabel("block size")
#	plt.ylabel("speedup")
#	plt.legend()
#	plt.title(f"Speedup for calculating average m=n={mat_size}")
#	plt.savefig(f"./writeup/reduce_plot_m{mat_size}.png", dpi=300)
#
