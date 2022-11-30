#!/usr/bin/env python

import sys
import numpy as np


T = 290  #  K
k = 8.31446261815324 / 1000   #  kJ/mol/K

#print(sys.argv)
filename = sys.argv[1]
outfilename = sys.argv[2]

r = []
pmf = []
with open(filename, "r") as f:
    for line in f:
        if "#" in line or "@" in line:
            continue
        line = line.strip().split()
        r.append(float(line[0]))
        pmf.append(float(line[1]))

r = np.array(r)
pmf = np.array(pmf)

pmf_corr = np.add(pmf, 2 * k * T * np.log(r))
print(pmf_corr)

with open(outfilename, "w") as of:
    for line in range(r.size):
        of.write("%.8e %.8e\n" % (r[line], pmf_corr[line]))
