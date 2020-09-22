#!/bin/bash

uname -r
rpm -qa | grep gluster

Files=( "dirty_ratio" "dirty_background_ratio" "swappiness" "vfs_cache_pressure"  )

for (( i = 0; i < ${#Files[@]} ; i++ ))
do
    echo "cat /proc/sys/vm/${Files[$i]}"
    cat /proc/sys/vm/${Files[$i]}
done

echo "cat /sys/block/sda/queue/scheduler"
cat /sys/block/sda/queue/scheduler
