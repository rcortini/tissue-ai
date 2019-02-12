from __future__ import print_function
import os, sys
import pandas as pd

# build directory names
tissue_ai_rootdir = "../"
experiments_dir = "%s/data/experiments"%(tissue_ai_rootdir)

# read metadata and build tissue-to-label mapping
md_fname = "%s/data/metadata.txt"%(tissue_ai_rootdir)
md = pd.read_csv(md_fname, sep='\t', low_memory=False)
tissues = md['Biosample term name'].unique()
tissues_mapping = {tissues[i] : i for i in range(len(tissues))}

# get the list of all the experiments
experiment_names = os.listdir(experiments_dir)
experiment_names.remove('toy')

# prepare the iteration over all the experiments
quants = []
labels = []
for experiment_name in experiment_names :
    
    # check that all the replicates from this experiment accession ID have the same tissue
    md_experiment = md[md['Experiment accession'] == experiment_name]
    tissue_id = md_experiment['Biosample term name'].unique()
    if tissue_id.size != 1 :
        raise ValueError("Experiment %s has replicates from different tissues"%(experiment_name))
    experiment_dir = "%s/%s"%(experiments_dir, experiment_name)
    
    # prepare the iteration over the replicates in the experiment
    replicate_n = 1
    replicate_dir = "%s/replicate-%d-quant"%(experiment_dir, replicate_n)
    while os.path.exists(replicate_dir) :
        quant_fname = "%s/quant-by-gene.tsv"%(replicate_dir)
        print(quant_fname)

        # increment the number of replicates
        replicate_n += 1
        replicate_dir = "%s/replicate-%d-quant"%(experiment_dir, replicate_n)

        # read the file and append it to our list
        quant = pd.read_csv(quant_fname, sep='\t', )
        quants.append(quant['GeneTPM'])
        labels.append(tissues_mapping[tissue_id[0]])

# create a Pandas DataFrame that will contain all our information
df = pd.DataFrame(data = quants, index = pd.RangeIndex(start=0, stop=len(quants)))
df['labels'] = labels

# save to file
df.to_csv("%s/data/dataset.tsv"%(tissue_ai_rootdir), sep='\t')
