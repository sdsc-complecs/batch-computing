#!/usr/bin/env bash

#SBATCH --job-name=roll-4-pi
#SBATCH --account=use300
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=00:02:00
#SBATCH --output=%x.o%j.%N

module reset
module load gcc/10.2.0
module load python/3.8.12
module list
printenv

time -p python3 pi.py 100000000
