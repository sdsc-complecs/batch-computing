# batch-computing
An introduction to batch computing on high-performance computing systems for non-programmers. 

### Exercise 0:
Clone this repo
```
git clone https://github.com/sdsc-complecs/batch-computing.git
```

### Exercise 1: Hello, my hostname is

```
#!/usr/bin/env bash

#SBATCH --job-name=hello-my-hostname-is
#SBATCH --account=gue998
#SBATCH --reservation=ciml25cpu
#SBATCH --partition=shared
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=00:05:00
#SBATCH --output=%x.o%j.%N

hostname
sleep 30
```

```
sbatch hello-my-hostname-is.sh
```

```
squeue -u $USER
```

```
[etrain102@login02 batch-computing]$ sbatch hello-my-hostname-is.sh 
Submitted batch job 40599374
[etrain102@login02 batch-computing]$ squeue -u $USER
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          40599374    shared hello-my etrain10  R       0:00      1 exp-1-03
[etrain102@login02 batch-computing]$
[etrain102@login02 batch-computing]$ ls -lahtr
total 179K
drwxr-x--- 5 etrain102 gue998   15 Jun 24 09:54 ..
-rw-r--r-- 1 etrain102 gue998 6.9K Jun 24 09:54 LICENSE
-rw-r--r-- 1 etrain102 gue998  380 Jun 24 09:54 Makefile
-rw-r--r-- 1 etrain102 gue998 5.5K Jun 24 09:54 README.md
-rw-r--r-- 1 etrain102 gue998  341 Jun 24 09:54 build-pi-omp.sh
-rw-r--r-- 1 etrain102 gue998  343 Jun 24 09:54 estimate-pi.sh
-rw-r--r-- 1 etrain102 gue998  304 Jun 24 09:54 hello-my-hostname-is.sh
drwxr-xr-x 2 etrain102 gue998    3 Jun 24 09:54 images
-rw-r--r-- 1 etrain102 gue998 1.4K Jun 24 09:54 pi.py
-rw-r--r-- 1 etrain102 gue998 2.9K Jun 24 09:54 pi_omp.f90
-rw-r--r-- 1 etrain102 gue998  391 Jun 24 09:54 roll-4-pi.sh
-rw-r--r-- 1 etrain102 gue998 2.8K Jun 24 09:54 run-gromacs-h2o.sh
-rw-r--r-- 1 etrain102 gue998  416 Jun 24 09:54 run-pi-omp.sh
-rw-r--r-- 1 etrain102 gue998 1.1K Jun 24 09:54 run-tf2-train-cnn-cifar.sh
-rw-r--r-- 1 etrain102 gue998 5.4K Jun 24 09:54 tf2-train-cnn-cifar.py
drwxr-xr-x 8 etrain102 gue998   13 Jun 24 09:54 .git
drwxr-xr-x 4 etrain102 gue998   18 Jun 24 09:54 .
-rw-r--r-- 1 etrain102 gue998    9 Jun 24 09:54 hello-my-hostname-is.o40599374.exp-1-03
[etrain102@login02 batch-computing]$ cat hello-my-hostname-is.o40599374.exp-1-03 
exp-1-03
[etrain102@login02 batch-computing]$
```

### Exercise 2: Roll 4 Pi

```
#!/usr/bin/env python3
#
# Estimate the value of Pi via Monte Carlo

import argparse
import math
import random

# Read in and parse input variables from command-line arguments
parser = argparse.ArgumentParser(description='Estimate the value of Pi via Monte Carlo')
parser.add_argument('samples', type=int,
                    help='number of Monte Carlo samples')
parser.add_argument('-v', '--verbose', action='store_true')
args = parser.parse_args()

# Initialize sample counts; inside will count the number of samples 
# that are located 'inside' the radius of a unit circle, while outside
# will count the number of samples that are located 'outside' the radius
# of a unit circle.
inside = 0
outside = 0

for i in range(1, args.samples):
    # Obtain two uniformly distributed random real numbers on unit interval
    x = random.random()
    y = random.random()

    # Compute radial distance of (x,y) from the origin of the unit circle
    z = math.sqrt(x**2 + y**2)

    # Increment sample count
    if z <= 1.0:
        inside += 1
    else:
        outside += 1

    # Compute intermediate estimate of Pi on the fly while the samples
    # are being collected
    if args.verbose:
        pi = 4 * inside / (inside + outside)
        print(pi)
else:
    # Compute final estimate of Pi once all samples have been collected
    pi = 4 * inside / (inside + outside)
    print(pi)
```

```
[etrain102@login02 batch-computing]$ python3 pi.py --help
usage: pi.py [-h] [-v] samples

Estimate the value of Pi via Monte Carlo

positional arguments:
  samples        number of Monte Carlo samples

optional arguments:
  -h, --help     show this help message and exit
  -v, --verbose
[etrain102@login02 batch-computing]$ python3 --version
Python 3.6.8
[etrain102@login02 batch-computing]$ which python3
/usr/bin/python3
[etrain102@login02 batch-computing]$ python3 pi.py 100
3.313131313131313
[etrain102@login02 batch-computing]$ python3 pi.py 1000
3.199199199199199
[etrain102@login02 batch-computing]$ python3 pi.py 10000
3.1343134313431342
[etrain102@login02 batch-computing]$
```

```
#!/usr/bin/env bash

#SBATCH --job-name=roll-4-pi
#SBATCH --account=gue998
#SBATCH --reservation=ciml25cpu
#SBATCH --partition=shared
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
```

```
[etrain102@login02 batch-computing]$ sbatch roll-4-pi.sh 
Submitted batch job 40599437
[etrain102@login02 batch-computing]$ squeue -u $USER
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          40599437    shared roll-4-p etrain10  R       0:03      1 exp-1-03
[etrain102@login02 batch-computing]$ squeue -u $USER
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          40599437    shared roll-4-p etrain10  R       0:14      1 exp-1-03
[etrain102@login02 batch-computing]$
[etrain102@login02 batch-computing]$ ls -lahtr
total 197K
-rw-r--r-- 1 etrain102 gue998 6.9K Jun 24 09:54 LICENSE
-rw-r--r-- 1 etrain102 gue998  380 Jun 24 09:54 Makefile
-rw-r--r-- 1 etrain102 gue998 5.5K Jun 24 09:54 README.md
-rw-r--r-- 1 etrain102 gue998  341 Jun 24 09:54 build-pi-omp.sh
-rw-r--r-- 1 etrain102 gue998  343 Jun 24 09:54 estimate-pi.sh
-rw-r--r-- 1 etrain102 gue998  304 Jun 24 09:54 hello-my-hostname-is.sh
drwxr-xr-x 2 etrain102 gue998    3 Jun 24 09:54 images
-rw-r--r-- 1 etrain102 gue998 1.4K Jun 24 09:54 pi.py
-rw-r--r-- 1 etrain102 gue998 2.9K Jun 24 09:54 pi_omp.f90
-rw-r--r-- 1 etrain102 gue998 2.8K Jun 24 09:54 run-gromacs-h2o.sh
-rw-r--r-- 1 etrain102 gue998  416 Jun 24 09:54 run-pi-omp.sh
-rw-r--r-- 1 etrain102 gue998 1.1K Jun 24 09:54 run-tf2-train-cnn-cifar.sh
-rw-r--r-- 1 etrain102 gue998 5.4K Jun 24 09:54 tf2-train-cnn-cifar.py
drwxr-xr-x 8 etrain102 gue998   13 Jun 24 09:54 .git
-rw-r--r-- 1 etrain102 gue998    9 Jun 24 09:54 hello-my-hostname-is.o40599374.exp-1-03
-rw-r--r-- 1 etrain102 gue998  391 Jun 24 09:58 roll-4-pi.sh
drwxr-x--- 5 etrain102 gue998   15 Jun 24 09:58 ..
drwxr-xr-x 4 etrain102 gue998   19 Jun 24 09:58 .
-rw-r--r-- 1 etrain102 gue998  15K Jun 24 09:59 roll-4-pi.o40599437.exp-1-03
[etrain102@login02 batch-computing]$ tail -n 4 roll-4-pi.o40599437.exp-1-03 
3.1414509514145097
real 62.72
user 62.23
sys 0.01
[etrain102@login02 batch-computing]$
```

### Exercise 3: Build Job, Run Job

```
[etrain102@login02 batch-computing]$ sbatch build-pi-omp.sh 
Submitted batch job 40599492
[etrain102@login02 batch-computing]$ squeue -u $USER
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
[etrain102@login02 batch-computing]$ ls -lahtr
total 249K
-rw-r--r-- 1 etrain102 gue998 6.9K Jun 24 09:54 LICENSE
-rw-r--r-- 1 etrain102 gue998  380 Jun 24 09:54 Makefile
-rw-r--r-- 1 etrain102 gue998 5.5K Jun 24 09:54 README.md
-rw-r--r-- 1 etrain102 gue998  341 Jun 24 09:54 build-pi-omp.sh
-rw-r--r-- 1 etrain102 gue998  343 Jun 24 09:54 estimate-pi.sh
-rw-r--r-- 1 etrain102 gue998  304 Jun 24 09:54 hello-my-hostname-is.sh
drwxr-xr-x 2 etrain102 gue998    3 Jun 24 09:54 images
-rw-r--r-- 1 etrain102 gue998 1.4K Jun 24 09:54 pi.py
-rw-r--r-- 1 etrain102 gue998 2.9K Jun 24 09:54 pi_omp.f90
-rw-r--r-- 1 etrain102 gue998 2.8K Jun 24 09:54 run-gromacs-h2o.sh
-rw-r--r-- 1 etrain102 gue998  416 Jun 24 09:54 run-pi-omp.sh
-rw-r--r-- 1 etrain102 gue998 1.1K Jun 24 09:54 run-tf2-train-cnn-cifar.sh
-rw-r--r-- 1 etrain102 gue998 5.4K Jun 24 09:54 tf2-train-cnn-cifar.py
drwxr-xr-x 8 etrain102 gue998   13 Jun 24 09:54 .git
-rw-r--r-- 1 etrain102 gue998    9 Jun 24 09:54 hello-my-hostname-is.o40599374.exp-1-03
-rw-r--r-- 1 etrain102 gue998  391 Jun 24 09:58 roll-4-pi.sh
drwxr-x--- 5 etrain102 gue998   15 Jun 24 09:58 ..
-rw-r--r-- 1 etrain102 gue998  15K Jun 24 09:59 roll-4-pi.o40599437.exp-1-03
-rw-r--r-- 1 etrain102 gue998 8.1K Jun 24 10:04 pi_omp.o
drwxr-xr-x 4 etrain102 gue998   22 Jun 24 10:04 .
-rwxr-xr-x 1 etrain102 gue998  24K Jun 24 10:04 pi_omp.x
-rw-r--r-- 1 etrain102 gue998  13K Jun 24 10:04 build-pi-omp.o40599492.exp-1-03
[etrain102@login02 batch-computing]$
```

```
[etrain102@login02 batch-computing]$ sbatch run-pi-omp.sh 
Submitted batch job 40599499
[etrain102@login02 batch-computing]$ squeue -u $USER
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          40599499    shared run-pi-o etrain10  R       0:02      1 exp-1-03
[etrain102@login02 batch-computing]$ squeue -u $USER
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          40599499    shared run-pi-o etrain10  R       0:17      1 exp-1-03
[etrain102@login02 batch-computing]$ squeue -u $USER
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          40599499    shared run-pi-o etrain10  R       0:52      1 exp-1-03
[etrain102@login02 batch-computing]$ squeue -u $USER
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
[etrain102@login02 batch-computing]$ ls -lahtr
total 267K
-rw-r--r-- 1 etrain102 gue998 6.9K Jun 24 09:54 LICENSE
-rw-r--r-- 1 etrain102 gue998  380 Jun 24 09:54 Makefile
-rw-r--r-- 1 etrain102 gue998 5.5K Jun 24 09:54 README.md
-rw-r--r-- 1 etrain102 gue998  341 Jun 24 09:54 build-pi-omp.sh
-rw-r--r-- 1 etrain102 gue998  343 Jun 24 09:54 estimate-pi.sh
-rw-r--r-- 1 etrain102 gue998  304 Jun 24 09:54 hello-my-hostname-is.sh
drwxr-xr-x 2 etrain102 gue998    3 Jun 24 09:54 images
-rw-r--r-- 1 etrain102 gue998 1.4K Jun 24 09:54 pi.py
-rw-r--r-- 1 etrain102 gue998 2.9K Jun 24 09:54 pi_omp.f90
-rw-r--r-- 1 etrain102 gue998 2.8K Jun 24 09:54 run-gromacs-h2o.sh
-rw-r--r-- 1 etrain102 gue998  416 Jun 24 09:54 run-pi-omp.sh
-rw-r--r-- 1 etrain102 gue998 1.1K Jun 24 09:54 run-tf2-train-cnn-cifar.sh
-rw-r--r-- 1 etrain102 gue998 5.4K Jun 24 09:54 tf2-train-cnn-cifar.py
drwxr-xr-x 8 etrain102 gue998   13 Jun 24 09:54 .git
-rw-r--r-- 1 etrain102 gue998    9 Jun 24 09:54 hello-my-hostname-is.o40599374.exp-1-03
-rw-r--r-- 1 etrain102 gue998  391 Jun 24 09:58 roll-4-pi.sh
drwxr-x--- 5 etrain102 gue998   15 Jun 24 09:58 ..
-rw-r--r-- 1 etrain102 gue998  15K Jun 24 09:59 roll-4-pi.o40599437.exp-1-03
-rw-r--r-- 1 etrain102 gue998 8.1K Jun 24 10:04 pi_omp.o
-rwxr-xr-x 1 etrain102 gue998  24K Jun 24 10:04 pi_omp.x
-rw-r--r-- 1 etrain102 gue998  13K Jun 24 10:04 build-pi-omp.o40599492.exp-1-03
drwxr-xr-x 4 etrain102 gue998   23 Jun 24 10:05 .
-rw-r--r-- 1 etrain102 gue998  13K Jun 24 10:06 run-pi-omp.o40599499.exp-1-03
[etrain102@login02 batch-computing]$ tail -n 4 run-pi-omp.o40599499.exp-1-03 
   3.1416177680000001     
real 56.65
user 226.16
sys 0.00
[etrain102@login02 batch-computing]$
```

### Exercise 4: GPU-Accelerated Workloads

```
[etrain102@login02 batch-computing]$ sbatch run-tf2-train-cnn-cifar.sh 
Submitted batch job 40599509
[etrain102@login02 batch-computing]$ squeue -u $USER
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          40599509 gpu-share train-cn etrain10  R       0:01      1 exp-4-58
[etrain102@login02 batch-computing]$ cat run-tf2-train-cnn-cifar.sh
#!/usr/bin/env bash

#SBATCH --job-name=train-cnn-cifar-c10-fp32-e42-bs256-tensorflow-22.08-tf2-py3-1v100
#SBATCH --account=gue998
#SBATCH --reservation=ciml25gpu
#SBATCH --partition=gpu-shared
#SBATCH --qos=gpu-shared-eot
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --cpus-per-task=1
#SBATCH --mem=92G
#SBATCH --gpus=1
#SBATCH --time=00:05:00
#SBATCH --output=%x.o%j.%N

declare -xr LOCAL_SCRATCH_DIR="/scratch/${USER}/job_${SLURM_JOB_ID}"
declare -xr LUSTRE_PROJECTS_DIR="/expanse/lustre/projects/${SLURM_JOB_ACCOUNT}/${USER}"
declare -xr LUSTRE_SCRATCH_DIR="/expanse/lustre/scratch/${USER}/temp_project"
declare -xr SINGULARITY_CONTAINER_DIR='/cm/shared/apps/containers/singularity'

declare -xr SINGULARITY_MODULE='singularitypro/3.11'

module purge
module load "${SINGULARITY_MODULE}"
module list
export KERAS_HOME="${LOCAL_SCRATCH_DIR}"
printenv

time -p singularity exec --bind "${KERAS_HOME}:/tmp" --nv "${SINGULARITY_CONTAINER_DIR}/tensorflow/tensorflow_22.08-tf2-py3.sif" \
  python3 -u tf2-train-cnn-cifar.py --classes 10 --precision fp32 --epochs 42 --batch_size 256
[etrain102@login02 batch-computing]$ squeue -u $USER
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          40599509 gpu-share train-cn etrain10  R       0:33      1 exp-4-58
[etrain102@login02 batch-computing]$ squeue -u $USER
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          40599509 gpu-share train-cn etrain10  R       1:00      1 exp-4-58
[etrain102@login02 batch-computing]$ squeue -u $USER
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          40599509 gpu-share train-cn etrain10  R       1:21      1 exp-4-58
[etrain102@login02 batch-computing]$ ls -lahtr
total 318K
-rw-r--r-- 1 etrain102 gue998 6.9K Jun 24 09:54 LICENSE
-rw-r--r-- 1 etrain102 gue998  380 Jun 24 09:54 Makefile
-rw-r--r-- 1 etrain102 gue998 5.5K Jun 24 09:54 README.md
-rw-r--r-- 1 etrain102 gue998  341 Jun 24 09:54 build-pi-omp.sh
-rw-r--r-- 1 etrain102 gue998  343 Jun 24 09:54 estimate-pi.sh
-rw-r--r-- 1 etrain102 gue998  304 Jun 24 09:54 hello-my-hostname-is.sh
drwxr-xr-x 2 etrain102 gue998    3 Jun 24 09:54 images
-rw-r--r-- 1 etrain102 gue998 1.4K Jun 24 09:54 pi.py
-rw-r--r-- 1 etrain102 gue998 2.9K Jun 24 09:54 pi_omp.f90
-rw-r--r-- 1 etrain102 gue998 2.8K Jun 24 09:54 run-gromacs-h2o.sh
-rw-r--r-- 1 etrain102 gue998  416 Jun 24 09:54 run-pi-omp.sh
-rw-r--r-- 1 etrain102 gue998 1.1K Jun 24 09:54 run-tf2-train-cnn-cifar.sh
-rw-r--r-- 1 etrain102 gue998 5.4K Jun 24 09:54 tf2-train-cnn-cifar.py
drwxr-xr-x 8 etrain102 gue998   13 Jun 24 09:54 .git
-rw-r--r-- 1 etrain102 gue998    9 Jun 24 09:54 hello-my-hostname-is.o40599374.exp-1-03
-rw-r--r-- 1 etrain102 gue998  391 Jun 24 09:58 roll-4-pi.sh
-rw-r--r-- 1 etrain102 gue998  15K Jun 24 09:59 roll-4-pi.o40599437.exp-1-03
-rw-r--r-- 1 etrain102 gue998 8.1K Jun 24 10:04 pi_omp.o
-rwxr-xr-x 1 etrain102 gue998  24K Jun 24 10:04 pi_omp.x
-rw-r--r-- 1 etrain102 gue998  13K Jun 24 10:04 build-pi-omp.o40599492.exp-1-03
-rw-r--r-- 1 etrain102 gue998  13K Jun 24 10:06 run-pi-omp.o40599499.exp-1-03
drwxr-xr-x 4 etrain102 gue998   24 Jun 24 10:09 .
drwxr-x--- 6 etrain102 gue998   16 Jun 24 10:09 ..
-rw-r--r-- 1 etrain102 gue998  42K Jun 24 10:10 train-cnn-cifar-c10-fp32-e42-bs256-tensorflow-22.08-tf2-py3-1v100.o40599509.exp-4-58
[etrain102@login02 batch-computing]$ less train-cnn-cifar-c10-fp32-e42-bs256-tensorflow-22.08-tf2-py3-1v100.o40599509.exp-4-58
[etrain102@login02 batch-computing]$ squeue -u $USER
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          40599509 gpu-share train-cn etrain10  R       1:35      1 exp-4-58
[etrain102@login02 batch-computing]$ squeue -u $USER
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
[etrain102@login02 batch-computing]$
[etrain102@login02 batch-computing]$ tail -n 20 train-cnn-cifar-c10-fp32-e42-bs256-tensorflow-22.08-tf2-py3-1v100.o40599509.exp-4-58
196/196 - 1s - loss: 0.4319 - accuracy: 0.8495 - 851ms/epoch - 4ms/step
Epoch 36/42
196/196 - 1s - loss: 0.4184 - accuracy: 0.8531 - 863ms/epoch - 4ms/step
Epoch 37/42
196/196 - 1s - loss: 0.4014 - accuracy: 0.8605 - 860ms/epoch - 4ms/step
Epoch 38/42
196/196 - 1s - loss: 0.3862 - accuracy: 0.8638 - 867ms/epoch - 4ms/step
Epoch 39/42
196/196 - 1s - loss: 0.3739 - accuracy: 0.8706 - 851ms/epoch - 4ms/step
Epoch 40/42
196/196 - 1s - loss: 0.3642 - accuracy: 0.8736 - 855ms/epoch - 4ms/step
Epoch 41/42
196/196 - 1s - loss: 0.3573 - accuracy: 0.8749 - 869ms/epoch - 4ms/step
Epoch 42/42
196/196 - 1s - loss: 0.3479 - accuracy: 0.8768 - 855ms/epoch - 4ms/step
40/40 - 0s - loss: 1.0874 - accuracy: 0.7057 - 307ms/epoch - 8ms/step
WARNING:absl:Found untraced functions such as _jit_compiled_convolution_op, _jit_compiled_convolution_op, _jit_compiled_convolution_op while saving (showing 3 of 3). These functions will not be directly callable after loading.
real 100.20
user 45.43
sys 12.96
[etrain102@login02 batch-computing]$
```

### Exercise 5: Multinode MPI Jobs

```
[etrain102@login02 batch-computing]$ sbatch run-gromacs-h2o.sh 
Submitted batch job 40599538
[etrain102@login02 batch-computing]$ squeue -u $USER
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          40599538   compute gromacs- etrain10  R       0:04      4 exp-1-[18-21]
[etrain102@login02 batch-computing]$ cat run-gromacs-h2o.sh 
#!/usr/bin/env bash

#SBATCH --job-name=gromacs-2020.4-2ufeq67-aocc-3.2.0-io3s466-openmpi-4.1.3-xigazqd-water-cut1.0_GMX50_bare-3072-4-node-128-mpi-1-omp
#SBATCH --account=gue998
#SBATCH --reservation=ciml25cpu
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
[etrain102@login02 batch-computing]$ squeue -u $USER
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          40599538   compute gromacs- etrain10  R       0:44      4 exp-1-[18-21]
[etrain102@login02 batch-computing]$ ssh exp-1-20
[etrain102@exp-1-20 ~]$ top -u $USER

top - 10:13:33 up 22 days, 18:13,  1 user,  load average: 0.11, 0.07, 0.01
Tasks: 1701 total,   1 running, 1700 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.1 us,  0.0 sy,  0.0 ni, 99.9 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem : 257485.8 total, 247548.9 free,   7519.7 used,   2417.2 buff/cache
MiB Swap:      0.0 total,      0.0 free,      0.0 used. 247934.3 avail Mem 

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND                                                       
1634731 etrain1+  20   0   60296   6104   3560 R   0.7   0.0   0:00.09 top                                                           
1634484 etrain1+  20   0   90584  10716   8260 S   0.0   0.0   0:00.07 systemd                                                       
1634487 etrain1+  20   0  163244  15788      0 S   0.0   0.0   0:00.00 (sd-pam)                                                      
1634574 etrain1+  20   0  139256   6544   4876 S   0.0   0.0   0:00.00 sshd                                                          
1634575 etrain1+  20   0   20768   5208   3272 S   0.0   0.0   0:00.05 bash                                                          












[etrain102@exp-1-20 ~]$ exit
logout
Connection to exp-1-20 closed.
[etrain102@login02 batch-computing]$ ls -lahtr
total 48M
-rw-r--r-- 1 etrain102 gue998 6.9K Jun 24 09:54 LICENSE
-rw-r--r-- 1 etrain102 gue998  380 Jun 24 09:54 Makefile
-rw-r--r-- 1 etrain102 gue998 5.5K Jun 24 09:54 README.md
-rw-r--r-- 1 etrain102 gue998  341 Jun 24 09:54 build-pi-omp.sh
-rw-r--r-- 1 etrain102 gue998  343 Jun 24 09:54 estimate-pi.sh
-rw-r--r-- 1 etrain102 gue998  304 Jun 24 09:54 hello-my-hostname-is.sh
drwxr-xr-x 2 etrain102 gue998    3 Jun 24 09:54 images
-rw-r--r-- 1 etrain102 gue998 1.4K Jun 24 09:54 pi.py
-rw-r--r-- 1 etrain102 gue998 2.9K Jun 24 09:54 pi_omp.f90
-rw-r--r-- 1 etrain102 gue998 2.8K Jun 24 09:54 run-gromacs-h2o.sh
-rw-r--r-- 1 etrain102 gue998  416 Jun 24 09:54 run-pi-omp.sh
-rw-r--r-- 1 etrain102 gue998 1.1K Jun 24 09:54 run-tf2-train-cnn-cifar.sh
-rw-r--r-- 1 etrain102 gue998 5.4K Jun 24 09:54 tf2-train-cnn-cifar.py
drwxr-xr-x 8 etrain102 gue998   13 Jun 24 09:54 .git
-rw-r--r-- 1 etrain102 gue998    9 Jun 24 09:54 hello-my-hostname-is.o40599374.exp-1-03
-rw-r--r-- 1 etrain102 gue998  391 Jun 24 09:58 roll-4-pi.sh
-rw-r--r-- 1 etrain102 gue998  15K Jun 24 09:59 roll-4-pi.o40599437.exp-1-03
-rw-r--r-- 1 etrain102 gue998 8.1K Jun 24 10:04 pi_omp.o
-rwxr-xr-x 1 etrain102 gue998  24K Jun 24 10:04 pi_omp.x
-rw-r--r-- 1 etrain102 gue998  13K Jun 24 10:04 build-pi-omp.o40599492.exp-1-03
-rw-r--r-- 1 etrain102 gue998  13K Jun 24 10:06 run-pi-omp.o40599499.exp-1-03
drwxr-x--- 6 etrain102 gue998   16 Jun 24 10:09 ..
drwxr-xr-x 4 etrain102 gue998    6 Jun 24 10:10 saved_model.40599509
-rw-r--r-- 1 etrain102 gue998  43K Jun 24 10:10 train-cnn-cifar-c10-fp32-e42-bs256-tensorflow-22.08-tf2-py3-1v100.o40599509.exp-4-58
drwxr-xr-x 3 etrain102 gue998    4 Jun 24 10:12 benchmarks
-rw-r--r-- 1 etrain102 gue998  12K Jun 24 10:13 mdout.gromacs-2020.4-2ufeq67-aocc-3.2.0-io3s466-openmpi-4.1.3-xigazqd-water-cut1.0_GMX50_bare-3072-4-node-128-mpi-1-omp.40599538.mdp
drwxr-xr-x 6 etrain102 gue998   29 Jun 24 10:13 .
-rw-r--r-- 1 etrain102 gue998  71M Jun 24 10:13 topol.gromacs-2020.4-2ufeq67-aocc-3.2.0-io3s466-openmpi-4.1.3-xigazqd-water-cut1.0_GMX50_bare-3072-4-node-128-mpi-1-omp.40599538.tpr
-rw-r--r-- 1 etrain102 gue998 465K Jun 24 10:13 gromacs-2020.4-2ufeq67-aocc-3.2.0-io3s466-openmpi-4.1.3-xigazqd-water-cut1.0_GMX50_bare-3072-4-node-128-mpi-1-omp.o40599538.exp-1-18
[etrain102@login02 batch-computing]$ less gromacs-2020.4-2ufeq67-aocc-3.2.0-io3s466-openmpi-4.1.3-xigazqd-water-cut1.0_GMX50_bare-3072-4-node-128-mpi-1-omp.o40599538.exp-1-18
[etrain102@login02 batch-computing]$ squeue -u $USER
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          40599538   compute gromacs- etrain10  R       1:15      4 exp-1-[18-21]
[etrain102@login02 batch-computing]$ ssh exp-1-18
[etrain102@exp-1-18 ~]$ top -u $USER

top - 10:13:58 up 22 days, 18:13,  1 user,  load average: 43.85, 10.39, 3.43
Tasks: 1861 total, 129 running, 1730 sleeping,   0 stopped,   2 zombie
%Cpu(s): 99.4 us,  0.1 sy,  0.0 ni,  0.0 id,  0.0 wa,  0.4 hi,  0.0 si,  0.0 st
MiB Mem : 257485.8 total, 237143.5 free,  17444.4 used,   2897.8 buff/cache
MiB Swap:      0.0 total,      0.0 free,      0.0 used. 237308.8 avail Mem 

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND                                                       
 813982 etrain1+  20   0  446248 109240  27500 R 100.0   0.0   0:22.74 gmx_mpi                                                       
 813843 etrain1+  20   0  414560 102760  26388 R  94.7   0.0   0:18.03 gmx_mpi                                                       
 813844 etrain1+  20   0  902312 248408  51712 R  94.7   0.1   0:17.90 gmx_mpi                                                       
 813846 etrain1+  20   0  498820 123228  27480 R  94.7   0.0   0:17.94 gmx_mpi                                                       
 813848 etrain1+  20   0  425936 102096  26816 R  94.7   0.0   0:20.12 gmx_mpi                                                       
 813849 etrain1+  20   0  426268 102928  27224 R  94.7   0.0   0:20.17 gmx_mpi                                                       
 813851 etrain1+  20   0  450716 110588  27600 R  94.7   0.0   0:20.15 gmx_mpi                                                       
 813852 etrain1+  20   0  418460 102736  26744 R  94.7   0.0   0:21.66 gmx_mpi                                                       
 813853 etrain1+  20   0  426484 102684  26792 R  94.7   0.0   0:21.53 gmx_mpi                                                       
 813854 etrain1+  20   0  429220 102716  27436 R  94.7   0.0   0:21.63 gmx_mpi                                                       
 813855 etrain1+  20   0  450760 111712  27472 R  94.7   0.0   0:21.64 gmx_mpi                                                       
 813857 etrain1+  20   0  425984 101804  26676 R  94.7   0.0   0:22.00 gmx_mpi                                                       
 813858 etrain1+  20   0  418484 102860  26652 R  94.7   0.0   0:22.08 gmx_mpi                                                       
 813859 etrain1+  20   0  454840 111264  27488 R  94.7   0.0   0:22.02 gmx_mpi                                                       
 813861 etrain1+  20   0  434464 101856  26748 R  94.7   0.0   0:22.37 gmx_mpi                                                       
 813876 etrain1+  20   0  455252 110800  27504 R  94.7   0.0   0:22.55 gmx_mpi                                                       
 813877 etrain1+  20   0  422524 103392  27200 R  94.7   0.0   0:22.55 gmx_mpi                                                       
[etrain102@exp-1-18 ~]$ exit
logout
Connection to exp-1-18 closed.
[etrain102@login02 batch-computing]$ ssh exp-1-20
Last login: Tue Jun 24 10:13:24 2025 from 10.21.0.20
[etrain102@exp-1-20 ~]$ top -u $USER

top - 10:14:08 up 22 days, 18:13,  1 user,  load average: 57.18, 14.33, 4.79
Tasks: 1836 total, 129 running, 1707 sleeping,   0 stopped,   0 zombie
%Cpu(s): 98.3 us,  1.2 sy,  0.0 ni,  0.0 id,  0.0 wa,  0.4 hi,  0.0 si,  0.0 st
MiB Mem : 257485.8 total, 236152.4 free,  18024.8 used,   3308.6 buff/cache
MiB Swap:      0.0 total,      0.0 free,      0.0 used. 236638.9 avail Mem 

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND                                                       
1634807 etrain1+  20   0  426388 105516  27796 R 105.3   0.0   0:33.57 gmx_mpi                                                       
1634756 etrain1+  20   0  416816 102240  26752 R 100.0   0.0   0:33.11 gmx_mpi                                                       
1634757 etrain1+  20   0  476364 131116  27708 R 100.0   0.0   0:33.22 gmx_mpi                                                       
1634758 etrain1+  20   0  414076 102548  26324 R 100.0   0.0   0:32.94 gmx_mpi                                                       
1634760 etrain1+  20   0  467988 127608  27736 R 100.0   0.0   0:33.27 gmx_mpi                                                       
1634761 etrain1+  20   0  418188 102740  26768 R 100.0   0.0   0:33.22 gmx_mpi                                                       
1634766 etrain1+  20   0  474812 129036  27512 R 100.0   0.0   0:33.21 gmx_mpi                                                       
1634771 etrain1+  20   0  418256 102616  26552 R 100.0   0.0   0:33.04 gmx_mpi                                                       
1634772 etrain1+  20   0  421564 102740  27052 R 100.0   0.0   0:33.12 gmx_mpi                                                       
1634773 etrain1+  20   0  481984 131512  27396 R 100.0   0.0   0:33.22 gmx_mpi                                                       
1634775 etrain1+  20   0  425224 102024  26780 R 100.0   0.0   0:32.97 gmx_mpi                                                       
1634778 etrain1+  20   0  434612 103832  27812 R 100.0   0.0   0:33.44 gmx_mpi                                                       
1634780 etrain1+  20   0  426588 102716  26964 R 100.0   0.0   0:33.49 gmx_mpi                                                       
1634784 etrain1+  20   0  420788 101992  27332 R 100.0   0.0   0:33.54 gmx_mpi                                                       
1634792 etrain1+  20   0  448020 105752  29408 R 100.0   0.0   0:33.54 gmx_mpi                                                       
1634795 etrain1+  20   0  427168 104096  27884 R 100.0   0.0   0:33.57 gmx_mpi                                                       
1634796 etrain1+  20   0  481100 133508  28292 R 100.0   0.1   0:33.26 gmx_mpi                                                       
[etrain102@exp-1-20 ~]$ exit
logout
Connection to exp-1-20 closed.
[etrain102@login02 batch-computing]$ squeue -u $USER
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          40599538   compute gromacs- etrain10  R       1:38      4 exp-1-[18-21]
[etrain102@login02 batch-computing]$ ssh exp-1-21
[etrain102@exp-1-21 ~]$ top -u $USER

top - 10:14:22 up 22 days, 18:14,  2 users,  load average: 72.76, 19.85, 6.78
Tasks: 1782 total, 129 running, 1652 sleeping,   0 stopped,   1 zombie
%Cpu(s): 98.0 us,  1.6 sy,  0.0 ni,  0.0 id,  0.0 wa,  0.4 hi,  0.0 si,  0.0 st
MiB Mem : 257485.8 total, 236012.8 free,  18162.4 used,   3310.5 buff/cache
MiB Swap:      0.0 total,      0.0 free,      0.0 used. 236835.2 avail Mem 

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND                                                       
1947503 etrain1+  20   0  476420 130632  27528 R 100.0   0.0   0:45.88 gmx_mpi                                                       
1947504 etrain1+  20   0  447064 106712  29220 R 100.0   0.0   0:45.91 gmx_mpi                                                       
1947505 etrain1+  20   0  412088 101508  26564 R 100.0   0.0   0:46.14 gmx_mpi                                                       
1947508 etrain1+  20   0  426660 102760  26740 R 100.0   0.0   0:45.93 gmx_mpi                                                       
1947517 etrain1+  20   0  483176 134036  27396 R 100.0   0.1   0:46.16 gmx_mpi                                                       
1947521 etrain1+  20   0  484824 132136  27484 R 100.0   0.1   0:45.75 gmx_mpi                                                       
1947524 etrain1+  20   0  484800 132252  27644 R 100.0   0.1   0:46.09 gmx_mpi                                                       
1947533 etrain1+  20   0  426188 102524  27184 R 100.0   0.0   0:46.52 gmx_mpi                                                       
1947542 etrain1+  20   0  482096 134992  28496 R 100.0   0.1   0:47.37 gmx_mpi                                                       
1947546 etrain1+  20   0  476608 131100  28324 R 100.0   0.0   0:47.38 gmx_mpi                                                       
1947550 etrain1+  20   0  481488 134084  28164 R 100.0   0.1   0:47.40 gmx_mpi                                                       
1947553 etrain1+  20   0  426036 103576  27856 R 100.0   0.0   0:47.34 gmx_mpi                                                       
1947556 etrain1+  20   0  434044 103316  28012 R 100.0   0.0   0:47.32 gmx_mpi                                                       
1947560 etrain1+  20   0  434524 103676  27784 R 100.0   0.0   0:47.41 gmx_mpi                                                       
1947561 etrain1+  20   0  438240 104424  28976 R 100.0   0.0   0:47.35 gmx_mpi                                                       
1947563 etrain1+  20   0  424948 102212  27568 R 100.0   0.0   0:47.42 gmx_mpi                                                       
1947564 etrain1+  20   0  433540 103108  28116 R 100.0   0.0   0:47.38 gmx_mpi                                                       
[etrain102@exp-1-21 ~]$ exit
logout
Connection to exp-1-21 closed.
[etrain102@login02 batch-computing]$ squeue -u $USER
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          40599538   compute gromacs- etrain10  R       1:51      4 exp-1-[18-21]
[etrain102@login02 batch-computing]$
```

# About COMPLECS

COMPLECS (COMPrehensive Learning for end-users to Effectively utilize
CyberinfraStructure) is a new SDSC program where training will cover
non-programming skills needed to effectively use
supercomputers. Topics include parallel computing concepts, Linux
tools and bash scripting, security, batch computing, how to get help,
data management and interactive computing. COMPLECS is supported by
NSF award 2320934.

<img src="./images/NSF_Official_logo_Med_Res_600ppi.png" alt="drawing" width="150"/>
