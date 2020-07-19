#!/usr/bin/env bash

for d in 00 01 02 03 04 05 06 07
do
    $HOME/local/julia-1.3.1/bin/julia -e 'FIRST_CASE = 1'$d'100000;'                \
                                      -e 'OUTPUT_DIR = "'$d'";'                     \
                                      -e 'DEVICE_TYPES = [:Line];'                  \
                                      -e 'RADIUS = 25;'                             \
                                      -e 'FRACTIONS = [1, 2, 5, 10, 20, 50, 100];'  \
                                      -e 'SAMPLE_SIZE = 1250;'                      \
                                      -L script.jl |& tee $d/Line.log               &
    sleep 150s
    $HOME/local/julia-1.3.1/bin/julia -e 'FIRST_CASE = 1'$d'200000;'                \
                                      -e 'OUTPUT_DIR = "'$d'";'                     \
                                      -e 'DEVICE_TYPES = [:Transformer2W];'         \
                                      -e 'RADIUS = 25;'                             \
                                      -e 'FRACTIONS = [1, 2, 5, 10, 20, 50, 100];'  \
                                      -e 'SAMPLE_SIZE = 1250;'                      \
                                      -L script.jl |& tee $d/Transformer2W.log      &
    sleep 150s
    $HOME/local/julia-1.3.1/bin/julia -e 'FIRST_CASE = 1'$d'300000;'                \
                                      -e 'OUTPUT_DIR = "'$d'";'                     \
                                      -e 'DEVICE_TYPES = [:Line, :Transformer2W];'  \
                                      -e 'RADIUS = 25;'                             \
                                      -e 'FRACTIONS = [1, 2, 5, 10, 20, 50, 100];'  \
                                      -e 'SAMPLE_SIZE = 1250;'                      \
                                      -L script.jl |& tee $d/Line,Transformer2W.log &
    sleep 150s
done

wait
