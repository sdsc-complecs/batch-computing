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

### Exercise 5: Multinode MPI Jobs

# About COMPLECS

COMPLECS (COMPrehensive Learning for end-users to Effectively utilize
CyberinfraStructure) is a new SDSC program where training will cover
non-programming skills needed to effectively use
supercomputers. Topics include parallel computing concepts, Linux
tools and bash scripting, security, batch computing, how to get help,
data management and interactive computing. COMPLECS is supported by
NSF award 2320934.

<img src="./images/NSF_Official_logo_Med_Res_600ppi.png" alt="drawing" width="150"/>
