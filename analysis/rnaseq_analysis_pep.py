import pandas as pd

data = pd.read_csv("dataset.tsv", sep = "\t", index_col = 0)
data_norm = data/data.sum(0)
samples = data_norm.transpose()
labels = pd.read_csv('labels.tsv', sep='\t', index_col = 0)
samples = samples.merge(labels, left_index = True, right_index = True)
