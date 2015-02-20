#!/bin/sh

for swapspace in $(swapon -s | awk '/zram/{print $1}'); do
    swapoff $swapspace
done
modprobe -r zram
