#!/usr/bin/env bash

#SBATCH --job-name=tda-ps
#SBATCH --output=tda-ps.log
#SBATCH --account siip
#SBATCH --time=20:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=6
#SBATCH --mem-per-cpu=5000


export TZ=:/etc/localtime

TIME="`which time` --verbose"

date -u

for f in example-*.jl nesta-*.jl rts-gmlc.jl
do
  l=${f%%.jl}.log
  srun --ntasks 1 $TIME julia --color=no --eval 'NO_INSTANTIATE=1 ; NESTA_CONTINGENCIES=100' --load $f &> $l &
done

wait

date -u
