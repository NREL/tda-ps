#!/usr/bin/env bash

#SBATCH --job-name=nesta-dynamic-contingency
#SBATCH --output=nesta-dynamic-contingency-batch.log
#SBATCH --account siip
#SBATCH --time=100:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=20000


export TZ=:/etc/localtime

TIME="`which time` --verbose"

date -u

while true
do
  srun --ntasks 1 $TIME julia --color=no --eval 'NO_INSTANTIATE=1 ; NESTA_CONTINGENCIES=50' --load nesta-dynamic-contingency.jl
  rm core.[[:digit:]]*
done

date -u
