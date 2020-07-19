#!/usr/bin/env bash

. $HOME/local/miniconda3/etc/profile.d/conda.sh
conda activate tda

date

for d in 00 01 02 03 04 05 06 07
do
    python measure.py $d &
done

wait
