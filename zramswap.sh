#!/bin/bash
# This script does the following:
# zramswap start:
#  * Create one ZRAM device and activate max_comp_stream accordingly to
#    number of CPUs on the system
#  * Space is assigned to each zram device, then swap is initialized on
#    there
# zramswap stop:
#  * Somewhat potentially dangerous, removes zram module at the end

function start {
    #Set some defaults:
    ALLOCATION=256 # ZRAM Swap you want assigned, in MiB
    PRIORITY=100   # Swap priority, see swapon(2) for more details

    # Get amount of available CPU cores, set to 1 if not detected correctly
    if [ ! -f /proc/cpuinfo ]; then
        echo "WARNING: Can't find /proc/cpuinfo, is proc mounted?"
        echo "         Using a single core for zramswap..."
        CORES=1
    else
        CORES=$(grep -c processor /proc/cpuinfo)
    fi

    # Override  above from config file, if it exists
    if [ -f /etc/default/zramswap ]; then
        . /etc/default/zramswap
    fi

    ALLOCATION=$((ALLOCATION * 1024 * 1024)) # convert amount from MiB to bytes

    if [ -n "$PERCENTAGE" ]; then
        totalmemory=$(awk '/MemTotal/{print $2}' /proc/meminfo) # in KiB
        ALLOCATION=$((totalmemory * 1024 * PERCENTAGE / 100))
    fi

    # Initialize zram devices, one device per CPU core
    modprobe zram num_devices=1
        # Use multiple cores
        echo "$CORES" > /sys/block/zram0/max_comp_streams
        echo "$ALLOCATION" > /sys/block/zram0/disksize
        mkswap /dev/zram0
        swapon -p "$PRIORITY" /dev/zram0

}

function status {
    for f in /sys/block/zram*/*_data_size ; do
        read -r size < "$f"
        what=$(basename "$f")
        eval "$what=\$(($what + $size))"
    done
    echo "compr_data_size: $((compr_data_size / 1024)) KiB"
    echo "orig_data_size:  $((orig_data_size  / 1024)) KiB"
    echo "print \"compression-ratio: \"; scale=2; $orig_data_size / $compr_data_size" | bc
}

function stop {
    for swapspace in $(swapon -s | awk '/zram/{print $1}'); do
        swapoff "$swapspace"
    done
    modprobe -r zram
}

function usage {
    echo "Usage:"
    echo "   zramswap start - start zram swap"
    echo "   zramswap stop - stop zram swap"
    echo "   zramswap status - prints some statistics"
}

if [ "$1" = "start" ]; then
    start
elif [ "$1" = "stop" ]; then
    stop
elif [ "$1" = "status" ]; then
    status
elif [ "$1" = "" ]; then
    usage
else echo "unknown option: $1";
fi
