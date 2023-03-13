#!/bin/bash

for i in 32 16 8 4 2 1
do
  #sudo timeout -s 9 400 ./test_zns.sh $i fs_delta_onode 2>&1 | tee result_zns_delta_onode_$i
  sudo timeout -s 9 400 ./test_zns_read.sh $i fs_delta_onode 2>&1 | tee result_with_read_zns_delta_onode_$i
  sudo timeout -s 9 400 ./test_zns_read.sh $i fs 2>&1 | tee result_with_read_zns_fs_$i
done

