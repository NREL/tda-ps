Running an R script on Eagle
============================


Set up a Conda environment
--------------------------

In order to use R on eagle, one needs to use Conda. Here is an example of setting up a Conda environment that has R and igraph installed:


	ssh eagle.hpc.nrel.gov
	module load conda
	conda create -n tda-ps -c conda-forge r r-igraph


Running the R script
--------------------

The [SLURM](https://www.nrel.gov/hpc/eagle-sample-batch-script.html) script [hello-eagle.slurm](hello-eagle.slurm) runs the simple R script [hello-eagle.R](hello-eagle.R). Edit the script to change the name of the job, the log file, the time limit, or the memory limit.

Submit the job using the `sbatch` command:

	sbatch hello-eagle.slurm

Monitor the job using the `squeue` command:

	squeue -u $USER

After the job finishes, view the output:

	cat hello-eagle.slurm
