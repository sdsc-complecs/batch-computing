# batch-computing
An introduction to batch computing on high-performance computing systems for non-programmers. 

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
