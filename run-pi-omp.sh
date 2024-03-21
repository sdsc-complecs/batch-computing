#!/usr/bin/env bash

#SBATCH --job-name=run-pi-omp
#SBATCH --account=use300
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=1G
#SBATCH --time=00:02:00
#SBATCH --output=%x.o%j.%N

module reset
module load gcc/10.2.0
module list
export OMP_NUM_THREADS="${SLURM_CPUS_PER_TASK}"
printenv

time -p ./pi_omp.x -s 10000000000
