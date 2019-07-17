
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans
data = pd.read_csv('../data/dataset.tsv', sep='\t', index_col = 0)
# eliminar columnes que sumin 0(el seguent)
data = data.drop(data.sum(0)[data.sum(0)==0].index, axis='columns')
# normalitzar(ferho tot sobre 1) i canviar files per columnes
data_norm = data/data.sum(0)
samples = data_norm.transpose()
labels = pd.read_csv('../data/labels.tsv', sep = '\t', index_col=0)
# fer la columna de label juntant els documents
samples = samples.merge(labels, left_index = True, right_index = True)

features = samples.iloc[:,:-1]

kmeans = KMeans(n_clusters=5).fit(features)
kmeans_cluster = kmeans.predict(features)

from sklearn.decomposition import PCA
pca = PCA(n_components = 2)
labels = pd.DataFrame(samples.iloc[:,-1])
pca.fit(features)
features_pca = pca.transform(features)

# val,label_idx = np.unique(labels, return_inverse = True)

plt.scatter(features_pca[:,0], features_pca[:,1], c = kmeans_cluster)
plt.show()


#pd.DataFrame(labels).merge(pd.DataFrame(kmeans_cluster, index = labels.index), right_index=True, left_index=True)
