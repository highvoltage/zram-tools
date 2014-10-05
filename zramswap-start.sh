#!/bin/sh
# This script does the following:
# zram start:
#  * zram doesn't natively support multiple CPU cores, so one zram device
#    is created for every CPU core minus one)
#  * Space is assigned to each zram device, then swap is initialized on
#    there

# Some defaults:
ALLOCATION=100 # ZRAM Swap you want assigned, in MiB
PRIORITY=100   # Swap priority, see swapon(2) for more details

# Get amount of available CPU cores, set to 1 if not detected correctly
if [ ! -f /proc/cpuinfo ]; then
    echo "WARNING: Can't find /proc/cpuinfo, is proc mounted?"
    echo "         Using a single core for zramswap..."
    cores=1
else
    cores=$(grep -c processor /proc/cpuinfo)
fi

# Override  above from config file, if it exists
if [ -f /etc/default/zramswap ]; then
    . /etc/default/zramswap
fi

ALLOCATION=$((ALLOCATION * 1000 * 1000)) #turn amount into MiB

# Initialize zram devices, one device per CPU core
modprobe zram num_devices=$cores

# Assign memory to zram devices, initialize swap and activate
# Decrementing $core, because cores start counting at 0
for core in $(seq 0 $(($cores - 1))); do
    echo $(($ALLOCATION / $cores)) > /sys/block/zram$core/disksize
    mkswap /dev/zram$core
    swapon -p $PRIORITY /dev/zram$core
done
