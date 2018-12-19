#!/bin/bash

# parse command line
if [ $# -ne 1 ]; then
  echo "Usage: $0 <tissue_ai_home>" 1>&2
  exit 1
fi

# get parameters
tissue_ai_home=$1

# preliminaries
root_dir=$(pwd)

# build iteration over experiments
experiments_dir="$tissue_ai_home/data/experiments"
experiment_dirs=$(find $experiments_dir -mindepth 1 -maxdepth 1 -type d)
log=$tissue_ai_home/data/jobs_launch.log
for experiment_dir in $experiment_dirs; do

  # extract the experiment name from the directory name
  experiment_name=${experiment_dir##*/}

  # build the name of the PBS script
  cd $experiment_dir
  pbs=download_and_quantify.pbs

  # launch job and write log
  jid=$(qsub -terse $pbs)
  echo "[`date +"%Y-%m-%d %H:%M:%S"`] : $experiment_name: $jid" >> $log

  cd $root_dir
done
