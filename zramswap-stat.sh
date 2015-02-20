#!/bin/sh
# This script gives information about
# how much data is currently stored, how much RAM is used for it
# and what the ratio is

for f in /sys/block/zram*/*_data_size ; do
    read size < $f
    what=$(basename $f)
    eval "$what=\$(($what + $size))"
done
echo "compr_data_size: $((compr_data_size / 1024)) KiB"
echo "orig_data_size:  $((orig_data_size  / 1024)) KiB"
echo "print \"compression-ratio: \"; scale=2; $orig_data_size / $compr_data_size" | bc

