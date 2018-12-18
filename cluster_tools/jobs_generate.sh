#!/bin/bash

# parse command line
if [ $# -ne 3 ]; then
  echo "Usage: jobs_generate.sh <tissue_ai_home> <metadata> <salmon_index>" 1>&2
  exit 1
fi

# get parameters
tissue_ai_home=$1
metadata=$2
salmon_index=$3

# files
experiments_dir="$tissue_ai_home/data/experiments"
pbs_in="$tissue_ai_home/cluster_tools/download_and_quantify.pbs.in"

# build iteration over experiments
experiment_dirs=$(find $experiments_dir -mindepth 1 -maxdepth 1 -type d)
for experiment_dir in $experiment_dirs; do

  # extract the experiment name from the directory name
  experiment_name=${experiment_dir##*/}

  # process the input PBS script and generate the output PBS script
  pbs_out="$experiment_dir/download_and_quantify.pbs"
  cat $pbs_in |\
    sed -e s,"@EXPERIMENT_NAME@","$experiment_name",g |\
    sed -e s,"@EXPERIMENT_DIR@","$experiment_dir",g |\
    sed -e s,"@TISSUE_AI_HOME@","$tissue_ai_home",g |\
    sed -e s,"@METADATA@","$metadata",g |\
    sed -e s,"@SALMON_INDEX@","$salmon_index",g |\
  tee > $pbs_out

done
