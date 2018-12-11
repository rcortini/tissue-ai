#!/bin/python

from __future__ import print_function
import pandas as pd
import sys, os

# check for proper invocation
if len(sys.argv) < 4 :
    print("Usage: metadata_get.py <metadata_fname> <exp_name> <column_name>",
          file = sys.stdout)
    sys.exit(1)

# get parameters from command line
metadata_fname = sys.argv[1]
exp_name = sys.argv[2]
column_name = sys.argv[3]

# load the metadata file
md = pd.read_csv(metadata_fname, sep='\t', low_memory=False)

# get the requested value
experiment = md.loc[md["File accession"] == exp_name]
print(experiment[column_name].values[0])
