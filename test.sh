#!/bin/bash

N=10
ITER=100

#/usr/local/cuda-12.3/bin/compute-sanitizer ./task2 -m $N -n $N -p $ITER -t
echo "==== global ===="
./task2_global -m $N -n $N -p $ITER -t
echo "==== surface ===="
./task2_surface -m $N -n $N -p $ITER -t


#echo "============= RUNNING TEST ================"
#echo "    ./task2 -m 15360 -n 15360 -p 1000 -t   "
#echo "==========================================="
#./task2 -m 15360 -n 15360 -p 1000 -t
