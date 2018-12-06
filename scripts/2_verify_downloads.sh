#!/bin/bash

# preliminaries
datadir="../data"
filtered="$datadir/filtered-files.txt"

while read line; do
  fname=${line##*/}
  if ! test -e $datadir/$fname; then
    echo "File $fname not found"
  fi
done < $filtered
