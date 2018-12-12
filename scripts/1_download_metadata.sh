#!/bin/bash

function time_string {
  echo "[`date +"%Y-%m-%d %H:%M:%S"`]"
}

function log_message {
  echo "`time_string` `basename $0`: INFO: $1"
}

# preliminaries
datadir="../data"
datafile="$datadir/files.txt"
metadata="$datadir/metadata.txt"
filtered="$datadir/filtered-files.txt"
filtered_metadata="$datadir/filtered-metadata.txt"

# first line is the metadata: download
log_message "Downloading metadata"
curl -o $metadata $(head -n1 $datafile)

# parse the metadata file: extract only the lines that contain tsv files
# that have a "gene quantifications" identifier
to_download=$(grep "gene quantifications" $metadata | grep .tsv | awk '{ print $1 }')

# the "to_download" list contains a series of files that correspond to URLs that
# we can fetch then with cURL. Let's write a list of files we want to dowlnoad.
rm -f $filtered
for id in $to_download; do
  file=$(grep $id $datafile)
  echo $file >> $filtered
done

# now we can do a batch download of the file list with a single invocation of
# cURL
root_dir=$(pwd)
cd $datadir
log_message "Begin batch file download"
xargs -L 1 curl -s -S -O -L < $filtered
log_message "Done"
cd $root_dir

# filter metadata file
log_message "Filtering metadata"
# extract the first line of the metadata file
head -n 1 $metadata > $filtered_metadata

# extract the codes of the experiments we downloaded
while read line; do
  fname=${line##*/}
  exp_name=$(echo $fname | sed -e s,.tsv,,)
  grep $exp_name $metadata >> $filtered_metadata
done < $filtered
