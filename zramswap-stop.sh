#!/bin/sh

for swapspace in $(swapon -s | grep zram | awk '{print $1}'); do
    swapoff $swapspace
done
modprobe -r zram
