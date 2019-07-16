#!/usr/bin/env bash

# Change the following line to set the job name.
#SBATCH --job-name=hello

# Change the following line to set the output log file.
#SBATCH --output=hello.log

# Change the following to set the time limit.
#SBATCH --time=5:00:00

# Change the following to set the memory required.
#SBATCH --mem-per-cpu=5000

# Comment out the following to avoid running in the debug queue.
#SBATCH --partition=debug

# Other parameters
#SBATCH --account siip
#SBATCH --nodes=1


# Load the conda module.
module load conda

# Use the "tda-ps" conda environment. That environment must have been previously created by running `module load conda; conda create -n tda-ps -c conda-forge r r-igraph`.
source activate tda-ps

# Put shell commands here.
srun Rscript hello-eagle.R
