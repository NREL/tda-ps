#!/usr/bin/env bash

. /opt/miniconda3a/etc/profile.d/conda.sh
conda activate tda

for d in 31 32 33 34 35 36 37 38
do
    python measure.py $d &
done

wait
