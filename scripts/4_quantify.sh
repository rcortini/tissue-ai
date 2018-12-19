#!/bin/bash

# parse command line
if [ $# -lt 3 ]; then
  echo "Usage: 4_quantify.sh <tissue_ai_home> <experiment_name> <nthreads>" 1>&2
  exit 1
fi

tissue_ai_home=$1
experiment_name=$2
nthreads=$3

source $tissue_ai_home/scripts/0_general_tools.sh
salmon=$tissue_ai_home/bin/salmon

# cd to directory
root_dir=$(pwd)
experiment_dir=$tissue_ai_home/data/experiments/$experiment_name
cd $experiment_dir

# init
let count=1
fname="replicate-$count.info"

# visit all the replicate files
while [ -e $fname ]; do

  # parse the replicate file
  run_type=$(head -n 1 $fname)
  if [ "$run_type" = "paired-ended" ]; then
    runs=($(tail -n 2 $fname | awk '{ print $1 }'))
  elif [ "$run_type" = "single-ended" ]; then
    runs=($(tail -n 1 $fname | awk '{ print $1 }'))
  fi
  
  # log file
  salmon_log="replicate-$count-salmon.log"

  # this step is the crucial one: notice that the LIB_TYPE argument (-l) given
  # to salmon has been chosen to A, so that salmon will try to automatically
  # figure out what type of library it is
  if [ "$run_type" = "paired-ended" ]; then
    $salmon quant -i $salmon_index -l A \
      -1 ${runs[0]}.fastq.gz -2 ${runs[1]}.fastq.gz \
      --threads $nthreads \
      -o replicate-$count-quant --validateMappings > $salmon_log
  elif [ "$run_type" = "single-ended" ]; then
    $salmon quant -i $salmon_index -l A \
      --threads $nthreads \
      -r ${runs[0]}.fastq.gz  \
      -o replicate-$count-quant --validateMappings > $salmon_log
  fi
 
  # increment counter and file name
  let count=count+1
  fname="replicate-$count.info"
done

# return back to original directory
cd $root_dir
