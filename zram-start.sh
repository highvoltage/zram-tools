#!/bin/sh
# This script does the following:
# zram start:
#  * zram doesn't natively support multiple CPU cores, so one zram device
#    is created for every CPU core minus one)
#  * Space is assigned to each zram device, then swap is initialized on
#    there

# BUG: this script currently assumes that it's the only thing using ZRAM,
#      and will fall over when a ZRAM device is already configured.

# Add to config...
#cores=...
#percentage=...
#ammount?=...

ASSIGNED_ZRAM_SWAP=1000 # Swap you want assigned in MiB
ASSIGNED_ZRAM_SWAP=$((ASSIGNED_ZRAM_SWAP * 1000 * 1000)) #turn amount into MiB

# Get amount of available CPU cores, set to 1 if not detected correctly
if [ ! -f /proc/cpuinfo ]; then
    echo "ERROR: Can't find /proc/cpuinfo, is proc mounted?"
    exit 1
else
    cores=$(grep -c processor /proc/cpuinfo)
fi

# Initialize zram devices, one device per CPU core
modprobe zram num_devices=$cores

# Assign memory to zram devices, initialize swap and activate
# Decrementing $core, because cores start counting at 0
for core in $(seq 0 $(($cores - 1))); do
    echo $(($ASSIGNED_ZRAM_SWAP / $cores)) > /sys/block/zram$core/disksize
    mkswap /dev/zram$core
    swapon -p 100 /dev/zram$core
done
