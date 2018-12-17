#!/bin/bash

function get_md5sum {
  grep "^$2" $1 | awk -F'\t' '{ print $35 }'
}

function get_URL {
  grep "^$2" $1 | awk -F'\t' '{ print $37 }'
}
