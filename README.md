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

In this section we describe how we proceed with the development of our AI. In
all the following, we will define an important variable which is the
`tissue_ai_home` directory, which is basically the directory that you cloned the
git repository to. The workflow requires that you set up your directories
correctly before starting.

### 3.1 Setting up the working directories
To set up the working directories, follow these steps.

1. Download the RNA-seq quantification program [Salmon](https://salmon.readthedocs.io).

2. When you have a working version of this
program, you should proceed with creating an index for the genome annotation
that you chose. Something like:
```bash
salmon index -t Homo_sapiens.GRCh38.cdna.all.fa.gz -i transcripts_index --type quasi -k 31
```
This will create a `transcripts_index` directory in the directory where you
executed this command. In order for the workflow to function correctly, you have
to create a symbolic link (or a copy) of this directory in
`<tissue_ai_home>/data/salmon_index`.

3. Create a symbolic link (or a copy) of the salmon executable file in
   `<tissue_ai_home>/bin`.

4. Download the list of all the RNA-seq experiments in Humans from the ENCODE
   web site. This is available through a [query of all the RNA-seq experiments
   performed in human cells](https://www.encodeproject.org/search/?type=Experiment&assay_term_name=RNA-seq&replicates.library.biosample.donor.organism.scientific_name=Homo+sapiens).
   Note that this list also contains experiments that have been retracted or
   have been classified as non reproducible. We will deal with the filtering
   later. Click on the "Download" button in the web page and save the files as
   `<tissue_ai_home>/data/files.txt`.


### 3.1 Pre-processing data

Once we set up the directories in this way, we are ready for the next steps. In
the first step, we download the metadata file of the experiments.

```bash
cd <tissue_ai_home>/scripts
bash 1_download_metadata.sh
```

In this way we obtain a list of experiment IDs that contain the data we want.
The next step is to prepare the directories to house the data we will look at.

```bash
python 2_prepare_directories.py
```

This script will create a list of directories under
`<tissue_ai_home>/data/experiments` that also contain files such as
`replicate-2.info` that contain the information (raw data file names, and
whether the experiment contains single-ended or paired-ended data) that we
will then download and quantify. **NOTE** this script requires the Python
`pandas` package.

### 3.2 Download and quantify

Now we are ready to download the raw files and run the quantification step. To
do this, it would require a substantial amount of time on an ordinary computer,
since each of the experiment contains many Gb of information. If you have access
to a cluster, skip to the paragraph below, otherwise you should run a simple bash
script such as (as usual fill the `tissue_ai_home=` line with the name of the
directory, and `nthreads=` with the number of threads you can dedicate to the
calcualations):

```bash
# to fill
tissue_ai_home=
nthreads=

# files and directories
experiments_dir=$tissue_ai_home/data/experiments
download=$tissue_ai_home/scripts/3_download_fastqs.sh
quantify=$tissue_ai_home/scripts/4_quantify.sh

# build iteration over experiments
experiment_dirs=$(find $experiments_dir -mindepth 1 -maxdepth 1 -type d)
for experiment_dir in $experiment_dirs; do

  # extract the experiment name from the directory name
  experiment_name=${experiment_dir##*/}

  # download and quantify
  bash $download $tissue_ai_home $experiment_name
  bash $quantify $tissue_ai_home $experiment_name

done
```

#### Execution on a cluster

This is to describe our support to cluster calculations, assuming that you have
a PBS-like queue scheduler.

The following script will generate a PBS script in the directory of each
experiment. Therefore, as a first step you should look at the template PBS file
in `<tissue_ai_home>/cluster_tools/download_and_quantify.pbs.in` and customize
it according to your needs.

```bash
cd <tissue_ai_home>/cluster_tools
bash jobs_generate.sh <tissue_ai_home> <nthreads>
```
where `nthreads` is the number of threads that each of the jobs on the cluster
will use. **NOTE HERE** that the `<tissue_ai_home>` variable on your cluster
will likely differ from the one that you are using on your computer!

When you verified that the PBS files have been correctly generated, it is
advisable to test the launch of one of them and see whether it succeeds. If you
feel confident that they can all run at the same time, you can execute

```bash
bash jobs_launch.sh <tissue_ai_home>
```
from your cluster. This will also create a log file under
`<tissue_ai_home>/data/jobs_launch.log`.

When your jobs terminated, you can run

```bash
bash jobs_verify.sh <tissue_ai_home> <submit>
```
where `submit` should be `yes` only if you want that the script resubmits the
PBS jobs if it finds that some jobs have not been executed correctly.

### 3.3 Post-processing data
We now have a list of directories containing the output of Salmon's
quantification step, which can be found in each experiment directory under
`<exp_dir>/replicate-n-quant/quant.sf`. This file contains the
*transcript-level* quantification of the experiment, and is typically quite
sparse. A good idea is to transform this table to a *gene-level* table. We will
do this with an R script that requires the libraries `dplyr` and `biomaRt`. The
former is a standard libarary, the latter should be installed using
Bioconductor. Please find the installation instructions [here](https://bioconductor.org/packages/release/bioc/html/biomaRt.html).

```bash
cd <tissue_ai_home>/scripts
./5_group_by_gene.R <tissue_ai_home>
```

This will generate in each replicate folder in each experiment directory another
file called `quant-by-gene.tsv`. These data files are the building block of our
Artificial Intelligence.
