#!/bin/bash

# check for proper invocation
if [ $# -ne 2 ]; then
  echo "Usage: jobs_verify.sh <tissue_ai_home> <submit>" 1>&2
  exit 1
fi

# get parameters from command line
tissue_ai_home=$1
submit=$2

# files and directories
log=$tissue_ai_home/data/jobs_launch.log
experiments_dir=$tissue_ai_home/data/experiments
root_dir=$(pwd)

# build iteration over experiments
experiment_dirs=$(find $experiments_dir -mindepth 1 -maxdepth 1 -type d)
for experiment_dir in $experiment_dirs; do

  # move to the experiment directory
  cd $experiment_dir

  # init
  let count=1
  fname="replicate-$count.info"

  # visit all the replicate files
  while [ -e $fname ]; do

    quant_file="$experiment_dir/replicate-$count-quant/quant.sf"
    if ! [ -s $quant_file ] ; then
      # extract the experiment name from the directory name
      experiment_name=${experiment_dir##*/}

      echo "$experiment_name INCOMPLETE"

      if [ "$submit" = "yes" ]; then
	# launch job and write log
	jid=$(qsub -terse $pbs)
	echo "[`date +"%Y-%m-%d %H:%M:%S"`] : $experiment_name: $jid" >> $log
      fi

      # no need to check the other replicate files
      break
    fi

    # increment counter and file name
    let count=count+1
    fname="replicate-$count.info"
  done

  cd $root_dir

done
