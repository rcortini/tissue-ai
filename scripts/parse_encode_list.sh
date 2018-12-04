#!/bin/bash

# preliminaries
datadir="../data"
datafile="$datadir/files.txt"
metadata="$datadir/metadata.txt"

# first line is the metadata: download
curl -o $metadata $(head -n1 $datafile)

# parse the metadata file: extract only the lines that contain tsv files
# that have a "gene quantifications" identifier
to_download=$(grep "gene quantifications" $metadata | grep .tsv | awk '{ print $1 }')

# the "to_download" list contains a series of files that correspond to URLs that
# we can fetch then with cURL
for id in $to_download; do
  file=$(grep $id $datafile)
  curl -L $file -o $datadir/$id.tsv
done
