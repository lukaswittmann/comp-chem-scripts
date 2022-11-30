#!/usr/bin/env python3

### Integrates F(t) using trapezoid rule
### does exponential averaging
### and calculates PMF as a function of the pull distance 

import sys
import argparse
import numpy as np
from scipy.integrate import cumtrapz

#xmgrace file reader
def read_xvg(filename,dtype=float):
    def iter_func():
        with open(filename,'r') as infile:
            for line in infile:
                if "#" not in line and "@" not in line and "&" not in line:
                    line = line.rstrip().split()
                    for item in line:
                        yield dtype(item)
        read_xvg.rowlength = len(line)
    data = np.fromiter(iter_func(), dtype=dtype)
    data = data.reshape(-1, read_xvg.rowlength).T
    return data

parser = argparse.ArgumentParser(description="Calculate work from forces and constant pull velocity.")
parser.add_argument('-f', required=True, help='List of filenames of forces F(t)')
parser.add_argument('-o', default='pmf.xvg', help='Name of output PMF file.')
parser.add_argument('-v', required=True, type=float, help='Pull velocity in nm/ps')
parser.add_argument('-rinit', required=True, type=float, help='Initial end-to-end distance.')
parser.add_argument('-T', required=True, type=float, help='Temperature in K')
args = vars(parser.parse_args())

k = 8.31446261815324 / 1000  # Boltzmann/gas constant in kJ / K / mol
T = args['T']

# Read names of force files
filenames = []
with open(args['f']) as f:
    for line in f:
        filenames.append(line.strip())

NFILES = len(filenames)
NLINES = read_xvg(filenames[0]).shape[1]

W = np.zeros((NFILES, NLINES - 1), dtype=np.float64)

# iterate over files and calculate work W
for index, filename in enumerate(filenames):
    data = read_xvg(filename)
    assert data.shape == (2, NLINES), f"Error reading file '{filename}'"
    time = data[0]
    force = data[1]
    assert time.size == NLINES, f"File '{filename}' has {time.size} lines, expected {NLINES}."
    W[index] = cumtrapz(force, dx=time[1] - time[0])

W *= args['v']

# Exponential averaging
PMF = - k * T * np.log(np.mean(np.exp(- W / (k * T)), axis=0))

with open(args['o'], "w") as of:
    of.write("@title \"PMF from Jarzynski equality\"\n")
    of.write("@xaxis  label \"End-to-end Distance (nm)\"\n")
    of.write("@yaxis  label \"PMF (kJ/mol)\"\n")
    for i in range(PMF.size):
        of.write("%.6f %.8e\n" % (args['rinit'] + time[i] * args['v'], PMF[i]))

print(f"PMF was written to '{args['o']}'")
