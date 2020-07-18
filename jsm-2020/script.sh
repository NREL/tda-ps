#!/usr/bin/env bash

for d in 00 01 02 03 04 05 06 07 08
do
    $HOME/local/julia-1.3.1/bin/julia -e 'FIRST_CASE = 1'$d'000000;'               \
                                      -e 'OUTPUT_DIR = "'$d'";'                    \
                                      -e 'DEVICE_TYPES = [:Line];'                 \
                                      -e 'RADIUS = 50;'                            \
                                      -e 'SAMPLE_SIZE = 625;'                      \
                                      -L script.jl                                 &
    $HOME/local/julia-1.3.1/bin/julia -e 'FIRST_CASE = 1'$d'000000;'               \
                                      -e 'OUTPUT_DIR = "'$d'";'                    \
                                      -e 'DEVICE_TYPES = [:Transformer2W];'        \
                                      -e 'RADIUS = 50;'                            \
                                      -e 'SAMPLE_SIZE = 625;'                      \
                                      -L script.jl                                 &
    $HOME/local/julia-1.3.1/bin/julia -e 'FIRST_CASE = 1'$d'000000;'               \
                                      -e 'OUTPUT_DIR = "'$d'";'                    \
                                      -e 'DEVICE_TYPES = [:Line, :Transformer2W];' \
                                      -e 'RADIUS = 50;'                            \
                                      -e 'SAMPLE_SIZE = 625;'                      \
                                      -L script.jl                                 &
done

wait
