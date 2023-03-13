#!/bin/bash

#targets="vanilla multi_zone append_no_lock fs fs_delta_onode"
targets="append_no_lock fs fs_delta_onode"

for i in 32 16 8 4 2 1
do
#  sudo timeout -s 9 400 ./test_zns_fs.sh $i 2>&1 | tee result_zns_fs_$i
  sudo timeout -s 9 800 ./test_cns.sh $i 2>&1 | tee result_cns_$i
#  sudo timeout -s 9 800 ./test_cns_seq.sh $i 2>&1 | tee result_cns_seq$i
  for target in $targets
  do
    #sudo timeout -s 9 400 ./test_zns_seq.sh $i ${target} 2>&1 | tee result_zns_${target}_seq_$i
    #sudo timeout -s 9 400 ./test_zns_wd.sh $i ${target}_wd 2>&1 | tee result_zns_${target}_wd_$i
    sudo timeout -s 9 400 ./test_zns.sh $i $target 2>&1 | tee result_zns_${target}_$i
  done
#  sudo timeout -s 9 400 ./test_zns_cns_fs.sh $i 2>&1 | tee result_zns_cns_fs_$i
done

sudo ./test_02.sh
