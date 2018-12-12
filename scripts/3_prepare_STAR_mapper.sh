#!/bin/bash

# parameters
nthreads=16
target_dir="/mnt/prj005866/tissue-ai/data/STAR/"
genome_dir="/mnt/shared/seq/GRCh38"
genome="$genome_dir/hg38.fasta"
gtf="$genome_dir/gencode.v29.chr_patch_hapl_scaff.annotation.gtf"
overhang=100

STAR --runThreadN $nthreads\
  --runMode genomeGenerate\
  --genomeDir $target_dir\
  --genomeFastaFiles \
  --sjdbGTFfile $gtf
  --sjdbOverhang $overhang
