#!/usr/bin/env bash

#SBATCH --job-name=gromacs-2020.4-2ufeq67-aocc-3.2.0-io3s466-openmpi-4.1.3-xigazqd-water-cut1.0_GMX50_bare-3072-4-node-128-mpi-1-omp
#SBATCH --account=use300
#SBATCH --partition=compute
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=128
#SBATCH --cpus-per-task=1
#SBATCH --mem=243G
#SBATCH --time=00:05:00
#SBATCH --output=%x.o%j.%N

declare -xr COMPILER_NAME='aocc'
declare -xr COMPILER_VERSION='3.2.0'
declare -xr COMPILER_VARIANT='io3s466'
declare -xr COMPILER_MODULE="${COMPILER_NAME}/${COMPILER_VERSION}/${COMPILER_VARIANT}"

declare -xr MPI_NAME='openmpi'
declare -xr MPI_VERSION='4.1.3'
declare -xr MPI_VARIANT='xigazqd'
declare -xr MPI_MODULE="${MPI_NAME}/${MPI_VERSION}/${MPI_VARIANT}"

declare -xr APPLICATION_NAME='gromacs'
declare -xr APPLICATION_VERSION='2020.4'
declare -xr APPLICATION_VARIANT='2ufeq67-omp'
declare -xr APPLICATION_MODULE="${APPLICATION_NAME}/${APPLICATION_VERSION}/${APPLICATION_VARIANT}"

declare -xr GROMACS_ROOT_URL='http://ftp.gromacs.org/pub'
declare -xr GROMACS_BENCHMARK='water-cut1.0_GMX50_bare'
declare -xr GROMACS_BENCHMARK_SIZE='3072'
declare -xr GROMACS_BENCHMARK_DATA_DIR="${SLURM_SUBMIT_DIR}/benchmarks/${GROMACS_BENCHMARK}/${GROMACS_BENCHMARK_SIZE}"
declare -xr GROMACS_BENCHMARK_TARBALL='water_GMX50_bare.tar.gz'

module reset
module load "${COMPILER_MODULE}"
module load "${MPI_MODULE}"
module load "${APPLICATION_MODULE}"
module list
export OMPI_MCA_btl='self,vader'
export UCX_TLS='shm,rc,ud,dc'
export UCX_NET_DEVICES='mlx5_2:1'
export UCX_MAX_RNDV_RAILS=1
export OMP_NUM_THREADS="${SLURM_CPUS_PER_TASK}"
export OMP_PLACES='cores'
export OMP_PROC_BIND='close'
printenv

if [[ ! -d "${SLURM_SUBMIT_DIR}/benchmarks" ]]; then
  mkdir -p "${SLURM_SUBMIT_DIR}/benchmarks"
fi

cd "${SLURM_SUBMIT_DIR}/benchmarks"

if [[ ! -d "${GROMACS_BENCHMARK_DATA_DIR}" ]]; then
  if [[ ! -f "${SLURM_SUBMIT_DIR}/benchmarks/${GROMACS_BENCHMARK_TARBALL}" ]]; then
    wget "${GROMACS_ROOT_URL}/benchmarks/${GROMACS_BENCHMARK_TARBALL}"
  fi
  tar -xzvf "${GROMACS_BENCHMARK_TARBALL}"
fi

cd "${SLURM_SUBMIT_DIR}"

time -p mpirun -n 1 gmx_mpi grompp \
  -f "${GROMACS_BENCHMARK_DATA_DIR}/pme.mdp" \
  -c "${GROMACS_BENCHMARK_DATA_DIR}/conf.gro" \
  -p "${GROMACS_BENCHMARK_DATA_DIR}/topol.top" \
  -po "mdout.${SLURM_JOB_NAME}.${SLURM_JOB_ID}.mdp" \
  -o "topol.${SLURM_JOB_NAME}.${SLURM_JOB_ID}.tpr"

time -p mpirun -n "${SLURM_NTASKS}" --bind-to core --map-by ppr:1:core:PE=1 \
  --display-allocation --display-map --report-bindings --verbose gmx_mpi mdrun \
  -nb cpu -pme cpu -bonded cpu -pin on -resethway -noconfout -nsteps 10000 \
  -s "topol.${SLURM_JOB_NAME}.${SLURM_JOB_ID}.tpr" \
  -cpo "state.${SLURM_JOB_NAME}.${SLURM_JOB_ID}.cpt" \
  -e "ener.${SLURM_JOB_NAME}.${SLURM_JOB_ID}.edr" \
  -g "md.${SLURM_JOB_NAME}.${SLURM_JOB_ID}.log" \
  -v
