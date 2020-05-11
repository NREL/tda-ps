#!/usr/bin/env bash

for d in 00
do
    $HOME/local/julia-1.3.1/bin/julia -E 'FIRST_CASE = 1'$d'000000;' \
                                      -E 'OUTPUT_DIR = "'$d'";'      \
                                      -E 'DEVICE_TYPE = :Line;'      \
                                      -E 'DEVICE_COUNTS = :([0]);'   \
                                      -E 'SAMPLE_SIZE = :(1);'       \
                                      -L script.jl
done

for d in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
do
    $HOME/local/julia-1.3.1/bin/julia -E 'FIRST_CASE = 1'$d'000000;' \
                                      -E 'OUTPUT_DIR = "'$d'";'      \
                                      -E 'DEVICE_TYPE = :Line;'      \
                                      -E 'DEVICE_COUNTS = :(1:200);' \
                                      -E 'SAMPLE_SIZE = :(1000);'    \
                                      -L script.jl                   &
done

wait
