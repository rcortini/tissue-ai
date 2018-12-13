#!/bin/bash

# preliminaries
datadir="../data"
datafile="$datadir/files.txt"
metadata="$datadir/metadata.txt"

# first line is the metadata: download
curl -o $metadata $(head -n1 $datafile)
