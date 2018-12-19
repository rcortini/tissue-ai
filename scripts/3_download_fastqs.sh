#!/bin/bash

function do_md5sum_test {
  # get arguments
  md=$1
  my_run=$2

  # prepare the md5sum test
  md5sum_fname=$(mktemp)
  sum=$(get_md5sum $md $my_run)
  echo "$sum $my_run.fastq.gz" > $md5sum_fname
  md5sum -c $md5sum_fname
}

# parse command line
if [ $# -lt 3 ]; then
  echo "Usage: download_and_quantify.sh <tissue_ai_home> <experiment_dir> <metadata>" 1>&2
  exit 1
fi

tissue_ai_home=$1
experiment_dir=$2
metadata=$3

source $tissue_ai_home/scripts/0_general_tools.sh

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
    run_urls=($(tail -n 2 $fname | awk '{ print $2 }'))
  elif [ "$run_type" = "single-ended" ]; then
    runs=$(tail -n 1 $fname | awk '{ print $1 }')
    run_urls=$(tail -n 1 $fname | awk '{ print $2 }')
  fi

  # iterate over all runs of the replicate
  for i in ${!runs[@]}; do

    # get values of the array
    run=${runs[i]}
    run_url=${run_urls[i]}

    # check if files exist already
    run_fname="$run.fastq.gz"
    if test -e $run_fname; then

      # if the file exists already, then we do the md5sum test
      do_md5sum_test $metadata $run

      # if test succeeded, it means that the file is already downloaded and we
      # can exit
      if [ $? -eq 0 ]; then
	continue
      else
	# if md5sum check failed on the file that already exists, then the most
	# likely explanation is that it was an incomplete download. In this case
	# we download it all over
	wget -nv $run_url
      fi
    else

      # if it does not exist, we download it
      wget -nv $run_url

      # after complete, we check for integrity
      do_md5sum_test $metadata $run

      # check that the test succeeded
      if [ $? -ne 0 ]; then
	# in this case something went seriously wrong, and we quit
	echo "Error: Corrupt FASTQ file for run $run" 1>&2
	exit 1
      fi
    fi
  done
  
  # increment counter and file name
  let count=count+1
  fname="replicate-$count.info"
done

# return back to original directory
cd $root_dir
