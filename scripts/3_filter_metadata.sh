#!/bin/bash

# preliminaries
datadir="../data"
metadata="$datadir/metadata.txt"
filtered="$datadir/filtered-files.txt"
filtered_metadata="$datadir/filtered-metadata.txt"

# extract the first line of the metadata file
head -n 1 $metadata > $filtered_metadata

# extract the codes of the experiments we downloaded
while read line; do
  fname=${line##*/}
  exp_name=$(echo $fname | sed -e s,.tsv,,)
  grep $exp_name $metadata >> $filtered_metadata
done < $filtered
