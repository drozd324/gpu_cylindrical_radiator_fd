#!/bin/bash

COLUMN_NAMES="m,n,block_size_x,block_size_y,cpu_time_allocating,time_allocating,speedup_time_allocating,cpu_time_compute,time_compute,speedup_time_compute,cpu_time_calc_averages,time_calc_averages,speedup_time_calc_averages"

FILE_NAME="writeup/task3.csv"
> FILE_NAME

NUM_ITER=10

POWERS=()
NUM_POWERS=11 #do 14

for ((i=0; i<$NUM_POWERS; i++)); do
	POWERS+=($((2 ** i)))
done


#BLOCK_SIZE=()
#MAX_BLOCK=
#for ((i=0; i<$; i++)); do
#	BLOCK_SIZE+=($((2 ** i)))
#done

echo "${POWERS[@]}"
echo $COLUMN_NAMES > $FILE_NAME

for (( i=0; i<$NUM_POWERS; i++ )); do
	for (( j=i; j<$NUM_POWERS; j++ )); do

			TEMP=$(./task2 -m ${POWERS[$j]} -n ${POWERS[$j]} -p $NUM_ITER -x ${POWERS[$i]} -y ${POWERS[$i]} -t)

		echo "./task2 -m ${POWERS[$j]} -n ${POWERS[$j]} -p $NUM_ITER -x ${POWERS[$i]} -y ${POWERS[$i]} -t"

	done
done
