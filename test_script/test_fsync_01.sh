#!/bin/bash

devs="sdc nvme0n1"
fsyncs="true false"
cpus="0-47 0-3"

for cpu in $cpus
do
	for dev in $devs
	do
		for fsync in $fsyncs
		do
			sudo ./test_typical.sh 16 /dev/$dev $fsync $cpu 2>&1 | tee result_fsync_${fsync}_${dev}_cpu_${cpu}
		done
	done
done

