#!/bin/bash

COLUMN_NAMES="m,n,block_size_x,block_size_y,cpu_time_allocating,time_allocating,speedup_time_allocating,cpu_time_compute,time_compute,speedup_time_compute,cpu_time_calc_averages,time_calc_averages,speedup_time_calc_averages"

FILE_NAME="writeup/task3.csv"

M=(1000 5000 10000 25000)
#N=(1000 5000 10000 25000)
BLOCK_SIZE_X=(2 4 8 16 32 64 128 256 512 1024)
#BLOCK_SIZE_Y=(2 4 8 16 32 64 128 256 512 1024)
NUM_ITER=100

POWERS=()
NUM_POWERS=4 #do 14

for ((i=0; i<$NUM_POWERS; i++)); do
	POWERS+=($((2 ** i)))
done

echo "${POWERS[@]}"
echo $COLUMN_NAMES > $FILE_NAME

for (( i=0; i<$NUM_POWERS; i++ )); do
	#echo "$i: ${my_array[$i]}"
	for (( j=i; j<$NUM_POWERS; j++ )); do

			TEMP=$(./task2 -m ${POWERS[$j]} -n ${POWERS[$j]} -p $NUM_ITER -x ${POWERS[$i]} -y ${POWERS[$i]} -t)

		echo "./task2 -m ${POWERS[$j]} -n ${POWERS[$j]} -p $NUM_ITER -x ${POWERS[$i]} -y ${POWERS[$i]} -t"

	done
done
