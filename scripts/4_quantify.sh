#!/bin/bash

source 0_general_tools.sh

# parse command line
if [ $# -lt 3 ]; then
  echo "Usage: 4_quantify.sh <experiment_dir> <metadata> <salmon_index>" 1>&2
  exit 1
fi

experiment_dir=$1
metadata=$2
salmon_index=$3

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
    runs=($(tail -n 2 $fname | awk '{ print $1 }'))
  elif [ "$run_type" = "single-ended" ]; then
    runs=($(tail -n 1 $fname | awk '{ print $1 }'))
  fi
  
  # before anything, check that all the downloaded files
  # have a correct md5sum
  md5sum_fname="replicate-$count.md5sum"
  md5sum_log="replicate-$count.md5sum.log"
  rm -f $md5sum_fname
  for run in ${runs[@]}; do
    sum=$(get_md5sum "$root_dir/$metadata" $run)
    echo "$sum $run.fastq.gz" >> $md5sum_fname
  done
  md5sum -c $md5sum_fname > $md5sum_log

  # proceed to quant step only if everything is okay
  if [ $? -eq 0 ]; then

    # log file
    salmon_log="replicate-$count-salmon.log"

    # this step is the crucial one: notice that the LIB_TYPE argument (-l) given
    # to salmon has been chosen to A, so that salmon will try to automatically
    # figure out what type of library it is
    if [ "$run_type" = "paired-ended" ]; then
      salmon quant -i $salmon_index -l A \
	-1 ${runs[0]}.fastq.gz -2 ${runs[1]}.fastq.gz \
	-o replicate-$count-quant --validateMappings > $salmon_log
    elif [ "$run_type" = "single-ended" ]; then
      salmon quant -i $salmon_index -l A \
	-r ${runs[0]}.fastq.gz  \
	-o replicate-$count-quant --validateMappings > $salmon_log
    fi
   
  else
    echo "md5sum check failed!"
    cat $md5sum_log
    exit 1
  fi

  # increment counter and file name
  let count=count+1
  fname="replicate-$count.info"
done

# return back to original directory
cd $root_dir
