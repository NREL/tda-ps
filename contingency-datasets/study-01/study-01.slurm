#!/usr/bin/env bash

#SBATCH --job-name=tda-ps-01
#SBATCH --output=study-01.log
#SBATCH --account siip
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=20000


export TZ=:/etc/localtime

TIME="`which time` --verbose"

date -u

srun --ntasks 1 $TIME julia --eval 'TDAPS_DIR = "../../simulations" ; NO_INSTANTIATE = true ; FIRST_CASE = 1 ; LAST_CASE = 10000' \
                            --load study-01.jl                                                                                    \
                            --color no
rm core.[[:digit:]]*

date -u
