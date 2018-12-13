#!/bin/python

import errno
import pandas as pd
import numpy as np
import os, sys

def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc:
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise

# directories and files
tissue_ai_rootdir = "../"
datadir = "%s/data"%(tissue_ai_rootdir)
md_fname = "%s/metadata.txt"%(datadir)
md = pd.read_csv(md_fname, sep='\t', low_memory=False)
fastqs = md.loc[md["File format"] == "fastq"]

# the collection of all the experiment accession IDs
experiment_names = fastqs["Experiment accession"].unique()

# iterate over all the experiments with an unique identifier
for experiment_name in experiment_names :
    
    # get the rows in the metadata table corresponding to this experiment
    experiment = fastqs.loc[fastqs["Experiment accession"] ==  experiment_name]
    
    # generate directory corresponding to the experiment
    experiment_dir = "%s/experiments/%s"%(datadir, experiment_name)
    mkdir_p(experiment_dir)

    # this list will allow us to keep track of which samples we have or have not
    # processed
    samples_processed = []
    
    # keep track of the sub-sample
    replicate_idx = 1

    # iterate over all the samples in the experiment
    for index, sample in experiment.iterrows() :
        
       
        # this is the case in which the sample is paired-ended: we need to find
        # which sample corresponds to the pair
        run_type = sample["Run type"]

        if run_type == "paired-ended" :
            
            # the identifier of the sample allows us to know which sample is paired
            # to the one we're visiting
            id_read1 = sample["File accession"]
            sample_paired = experiment.loc[experiment["Paired with"] ==  id_read1].iloc[0]
            id_read2 = sample_paired["File accession"]
                        
            # if we haven't already processed the sample, print the results
            if id_read1 not in samples_processed :

                 # fname
                fname = "%s/replicate-%d.info"%(experiment_dir, replicate_idx)
               
                # open file
                f = open(fname, 'w')

                # write what type we're looking at in the replicate info file
                f.write("%s\n"%(run_type))

                # write experiment info
                f.write("%s %s\n"%(id_read1, sample["File download URL"]))
                f.write("%s %s\n"%(id_read2, sample_paired["File download URL"]))

                # increment the replicate index
                replicate_idx += 1

            # add the paired samples to the list of samples that we processed
            samples_processed.append(id_read1)
            samples_processed.append(id_read2)

        # this case is the case of single-ended
        elif run_type ==  "single-ended" :
             # fname
            fname = "%s/replicate-%d.info"%(experiment_dir, replicate_idx)
           
            # open file
            f = open(fname, 'w')

            # write what type we're looking at in the replicate info file
            f.write("%s\n"%(run_type))

            # write experiment info
            f.write("%s %s\n"%(sample["File accession"], sample["File download URL"]))

            # increment the replicate index
            replicate_idx += 1

        else :
            raise(ValueError, "Invalid run type: %s"%run_type)
        
        # close file
        f.close()
