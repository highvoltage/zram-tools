zram-tools
==========

Scripts for managing zram swap devices.

zramswap-start
--------------

Sets up zram devices and initializes swap. zram doesn't natively support
multiple processors, so by default a zram device is set up for every
core and then swap is initialized on those devices. This is configurable
in the zramswap config file.

zramswap-stop
-------------

Removes all current zram swap spaces and devices.

zramswap-stat
-------------

shows information on data stored in zram swap.

/etc/default/zramswap
---------------------

Configuration file for zramswap-start
