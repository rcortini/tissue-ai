import pandas as pd
# PCA in order to reduce the number of dimensions
from sklearn.decomposition import PCA
import matplotlib.pyplot as plt
# KMeans fa agrupacions per clusters
from sklearn.cluster import KMeans

# Llegim data.
data = pd.read_csv("../data/dataset.tsv", sep = "\t", index_col = 0)
# Eliminem columnes que sumen 0 per tal que no dongui error.
data = data.drop(data.sum(0)[data.sum(0) == 0].index, axis = 'columns')

# Normalitzem les dades
data_norm = data/data.sum(0)

# Canviem files per columnes
samples = data_norm.transpose()
labels = pd.read_csv('../data/labels.tsv', sep='\t', index_col = 0)
samples = samples.merge(labels, left_index = True, right_index = True)

features = samples.iloc[:,:-1]
labels = pd.DataFrame(samples.iloc[:,-1])

pd.DataFrame(labels).merge(pd.DataFrame(kmean_clusters, index = labels.index), right_index = True, left_index = True)                                                       

# Fem la PCA de n components
pca = PCA(n_components = 2)
pca.fit(features)
features_pca = pca.transform(features)

# plt.scatter(features_pca[:,0], features_pca[:,1], c = kmean_clusters)

kmeans = KMeans(n_clusters = 15).fit(features)
kmean_clusters = kmeans.predict(features)                                                                                                                                   

