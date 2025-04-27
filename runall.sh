#!/bin/bash

cd "$(dirname "$(realpath "$0")")" || exit 1

cd ./double

bash ./task3.sh 
bash ./task3_old_reduce.sh 

cd ../float

bash ./task3.sh
bash ./task3_old_reduce.sh
