#!/bin/bash

# preliminaries
datadir="../data"
filtered="$datadir/filtered-files.txt"
filtered_metadata="$datadir/filtered-metadata.txt"

# check if all files were downloaded
while read line; do
  fname=${line##*/}
  if ! test -e $datadir/$fname; then
    echo "$fname: NOT found"
  fi
done < $filtered

# to do md5sum, get the column of the metadata file corresponding to md5sum
line=$(head -n 1 $filtered_metadata)
IFS=$':' fields=(${line//$'\t'/:})
for (( i=0; i<${#fields[@]} ; i++ )); do
  if [ "${fields[i]}" = "md5sum" ]; then
    let idx=i+1
  fi
done

awk -v var="$idx" -v datadir="$datadir" -F $'\t' \
  'BEGIN {OFS = FS} {fname=$1; md5=$var; printf("%s %s/%s.tsv\n", md5, datadir, fname) }' $filtered_metadata |\
  tail -n +2 | md5sum -c --quiet
