#!/bin/bash

NUM_RBD=$1

sudo ./bringup_cns.sh
sudo ../build/bin/ceph osd pool create bench 32 32
RBDS=$(seq 1 $NUM_RBD)
#FIO_CMD="sudo fio --ioengine=rbd --clientname admin --pool bench --ramp_time 1m --bs 4k --readwrite randwrite --invalidate 0 --direct 1 --group_reporting --time_based --runtime 2m --numjobs 1 --thread --iodepth 32"
FIO_CMD="sudo fio --ioengine=rbd --clientname admin --pool bench --bs 4k --eta-interval 1 --eta-newline 1 --readwrite randwrite --invalidate 0 --direct 1 --group_reporting --time_based --runtime 3m --numjobs 1 --thread --iodepth 32"
for i in $RBDS
do
  sudo ../build/bin/rbd create test_$i -p bench --size 10G
  FIO_CMD="$FIO_CMD --name job_$i --rbdname test_$i"
done
echo $FIO_CMD
$FIO_CMD
