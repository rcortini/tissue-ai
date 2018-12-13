#!/bin/bash

# parse command line
if [ $# -lt 1 ]; then
  echo "Usage: download_and_quantify.sh <experiment_dir>" 1>&2
  exit 1
fi

experiment_dir=$1

# cd to directory
root_dir=$(pwd)
cd $experiment_dir

# init
let count=1
fname="replicate-$count.info"

# visit all the replicate files
while [ -e $fname ]; do

  # parse the replicate file
  run_type=$(head -n 1 $fname)
  if [ "$run_type" = "paired-ended" ]; then
    runs=$(tail -n 2 $fname | awk '{ print $2 }')
  elif [ "$run_type" = "single-ended" ]; then
    runs=$(tail -n 1 $fname | awk '{ print $2 }')
  fi
  
  # download
  for run in $runs; do
    wget $run
  done

  # increment counter and file name
  let count=count+1
  fname="replicate-$count.info"
done

# return back to original directory
cd $root_dir
