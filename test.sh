#!/bin/bash

N=1000
ITER=100

#/usr/local/cuda-12.3/bin/compute-sanitizer ./task2 -m $N -n $N -p $ITER -t
./task2 -m $N -n $N -p $ITER -t


#echo "============= RUNNING TEST ================"
#echo "    ./task2 -m 15360 -n 15360 -p 1000 -t   "
#echo "==========================================="
#./task2 -m 15360 -n 15360 -p 1000 -t
