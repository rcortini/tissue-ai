# Tissue AI

Artificial Intelligence project by **Ruggero Cortini** (rcortini) and **Eduard
Valera** (ezorita).

## 1. Introduction

Every cell type in the human body has a distinct identity. A neuron and a
pancreatic cell behave in very different ways: a neuron produces
neurotransmitters, whereas pancreatic cells don't; conversely, pancreatic cells
produce insulin, whereas neurons don't. This observation is somewhat surprising
because the DNA contained in both cell types is exactly the same. That is to
say, the *instructions* needed to produce both neurotransmitter and insulin is
contained by both neurons and pancreatic cells. A major area of current research
aims at understanding where these differences come from, and how they are
mantained.

The differences between cell types can be identified by looking at the RNA
products of the cells. Modern sequencing technologies allow to measure the
amount of RNA that each cell contains, allowing for an accurate reconstruction
of the cell identity. This technology is called RNA-seq. Each cell type has its
own signature in terms of the RNA that it produces, which can be captured by
RNA-seq experiments.

Recently, large amounts of biological data has become available through large
collective efforts of publishing experimental data sets. The [ENCODE
project](https://www.encodeproject.org) (ENCyclopedia OF DNA Elements) is one of
these, and currently contains thousands of publicly available experimental data
sets. Among these, there are currently 889 RNA-seq experiments performed in
human cells. This large amount of data renders it amenable to be used in Machine
Learning.

The main aim of this project is to train modern Artificial Intelligence
frameworks to process RNA-seq data sets and extract its patterns.

## 2. Objectives

1. Build a *predictive* AI to take an RNA-seq experiment and predict what cell
   type it belongs to
2. Have the AI predict the expression of a subset of genes, given the
   information of the expression of a subset of other genes.

## 3. Workflow

In this section we describe how we proceed with the development of our AI.

### 3.1 Data download and preprocessing

In the first part of the work, we will download the list of files from the
ENCODE web site. This is available through a [query of all the RNA-seq
experiments performed in human cells](https://www.encodeproject.org/search/?type=Experiment&assay_term_name=RNA-seq&replicates.library.biosample.donor.organism.scientific_name=Homo+sapiens).

We click on the "Download" button in the web page and save the files as
`data/files.txt`, in the root directory of the `tissue-ai` project.

We then execute the script:

```
cd scripts
bash parse_encode_list.sh
```

This script will first download a "metadata" file which will contain the
information on the experimental data we are about to download. Then it will
extract all the names of the experiment identifiers that correspond to
tab-separated files (tsv) which are identified as "gene quantifications". This
step is necessary to obtained files that have an homogeneous structure, and
avoid us from processing an enormous amount of raw data.
