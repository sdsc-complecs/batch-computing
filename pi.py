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
