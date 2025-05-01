# batch-computing
An introduction to batch computing on high-performance computing systems for non-programmers. 

### Step 1:
Clone this repo
```
[etrain76@login01]$ git clone https://github.com/sdsc-complecs/batch-computing.git
Cloning into 'batch-computing'...
remote: Enumerating objects: 91, done.
remote: Counting objects: 100% (91/91), done.
remote: Compressing objects: 100% (88/88), done.
remote: Total 91 (delta 38), reused 5 (delta 2), pack-reused 0 (from 0)
Receiving objects: 100% (91/91), 165.37 KiB | 2.30 MiB/s, done.
Resolving deltas: 100% (38/38), done.
[etrain76@login01 wrkshp-prep]$ cd batch-computing/
[etrain76@login01 batch-computing]$ ls -al
total 179
drwxr-xr-x 4 etrain76 gue998   17 May  1 07:12 .
drwxr-xr-x 5 etrain76 gue998    5 May  1 07:12 ..
-rw-r--r-- 1 etrain76 gue998  308 May  1 07:12 build-pi-omp.sh
-rw-r--r-- 1 etrain76 gue998  311 May  1 07:12 estimate-pi.sh
drwxr-xr-x 8 etrain76 gue998   13 May  1 07:12 .git
-rw-r--r-- 1 etrain76 gue998  271 May  1 07:12 hello-my-hostname-is.sh
drwxr-xr-x 2 etrain76 gue998    3 May  1 07:12 images
-rw-r--r-- 1 etrain76 gue998 7048 May  1 07:12 LICENSE
-rw-r--r-- 1 etrain76 gue998  380 May  1 07:12 Makefile
-rw-r--r-- 1 etrain76 gue998 2929 May  1 07:12 pi_omp.f90
-rw-r--r-- 1 etrain76 gue998 1385 May  1 07:12 pi.py
-rw-r--r-- 1 etrain76 gue998 5461 May  1 07:12 README.md
-rw-r--r-- 1 etrain76 gue998  358 May  1 07:12 roll-4-pi.sh
-rw-r--r-- 1 etrain76 gue998 2801 May  1 07:12 run-gromacs-h2o.sh
-rw-r--r-- 1 etrain76 gue998  383 May  1 07:12 run-pi-omp.sh
-rw-r--r-- 1 etrain76 gue998 1027 May  1 07:12 run-tf2-train-cnn-cifar.sh
-rw-r--r-- 1 etrain76 gue998 5502 May  1 07:12 tf2-train-cnn-cifar.py
```

### Exercise 1: Hello, my hostname is

```
#!/usr/bin/env bash

#SBATCH --job-name=hello-my-hostname-is
#SBATCH --account=use300
#SBATCH --partition=debug
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
[mkandes@login02 ~]$ vi hello-my-hostname-is.sh 
[mkandes@login02 ~]$ ls
datasets  hello-my-hostname-is.sh  projects  scripts  software
[mkandes@login02 ~]$ sbatch hello-my-hostname-is.sh 
Submitted batch job 29394313
[mkandes@login02 ~]$ sbatch hello-my-hostname-is.sh 
Submitted batch job 29394314
[mkandes@login02 ~]$ squeue -u $USER
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          29394314     debug hello-my  mkandes  R       0:03      1 exp-9-55
          29394313     debug hello-my  mkandes  R       0:04      1 exp-9-55
[mkandes@login02 ~]$ squeue -j 29394313
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          29394313     debug hello-my  mkandes  R       0:21      1 exp-9-55
[mkandes@login02 ~]$ ls
datasets                                 hello-my-hostname-is.sh  software
hello-my-hostname-is.o29394313.exp-9-55  projects
hello-my-hostname-is.o29394314.exp-9-55  scripts
[mkandes@login02 ~]$ cat hello-my-hostname-is.o29394313.exp-9-55
exp-9-55
[mkandes@login02 ~]$
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
[mkandes@login02 ~]$ vi pi.py
[mkandes@login02 ~]$ python3 pi.py --help
usage: pi.py [-h] [-v] samples

Estimate the value of Pi via Monte Carlo

positional arguments:
  samples        number of Monte Carlo samples

optional arguments:
  -h, --help     show this help message and exit
  -v, --verbose
[mkandes@login02 ~]$ python3 --version
Python 3.6.8
[mkandes@login02 ~]$ which python3
/usr/bin/python3
[mkandes@login02 ~]$ python3 pi.py 100
2.98989898989899
[mkandes@login02 ~]$ python3 pi.py 1000
3.191191191191191
[mkandes@login02 ~]$ python3 pi.py 10000
3.1375137513751374
[mkandes@login02 ~]$
```

```
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
```

```
[mkandes@login02 ~]$ ls
datasets                                 hello-my-hostname-is.sh  roll-4-pi.sh
hello-my-hostname-is.o29394313.exp-9-55  pi.py                    scripts
hello-my-hostname-is.o29394314.exp-9-55  projects                 software
[mkandes@login02 ~]$ sinfo -p debug
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
debug        up      30:00      1   plnd exp-9-56
debug        up      30:00      1    mix exp-9-55
[mkandes@login02 ~]$ sbatch roll-4-pi.sh 
Submitted batch job 29402750
[mkandes@login02 ~]$ squeue -u $USER
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          29402750     debug roll-4-p  mkandes  R       0:22      1 exp-9-55
[mkandes@login02 ~]$ squeue -u $USER
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
[mkandes@login02 ~]$ tail -n 4 roll-4-pi.o29402750.exp-9-55 
3.1413662714136628
real 62.54
user 62.36
sys 0.01
[mkandes@login02 ~]$
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
