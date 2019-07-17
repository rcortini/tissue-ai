import os, sys
import pandas as pd

# build directory names
tissue_ai_rootdir = "../"
experiments_dir = "%s/data/experiments"%(tissue_ai_rootdir)

# read metadata and build tissue-to-label mapping
md_fname = "%s/data/metadata.txt"%(tissue_ai_rootdir)
md = pd.read_csv(md_fname, sep='\t', low_memory=False)
tissues = md['Biosample term name'].unique()

# get the list of all the experiments
experiment_names = os.listdir(experiments_dir)
experiment_names.remove('toy')

# prepare the iteration over all the experiments
quants = pd.DataFrame()
labels = {}
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

        # increment the number of replicates
        replicate_dir = "%s/replicate-%d-quant"%(experiment_dir, replicate_n)
        exp_id = '%s-%d'%(experiment_name, replicate_n)

        # read the file and append it to our list
        quant = pd.read_csv(quant_fname, sep='\t')
        quants.loc[:, exp_id] = quant['GeneTPM']
        labels[exp_id] = tissue_id[0]

        # increment replicate index
        print(quant_fname)
        replicate_n += 1

# create a DataFrame that will contain the expression patterns, and save it
quants = quants.set_index(quant['GeneID'])
quants.to_csv("%s/data/dataset.tsv"%(tissue_ai_rootdir), sep='\t')

# and create the labels DataFrame, and save it
df = pd.DataFrame(list(labels.items()), columns = ['Experiment_ID', 'Tissue'])
df.to_csv("%s/data/labels.tsv"%(tissue_ai_rootdir), sep='\t', index=False)
