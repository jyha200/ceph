#!/bin/bash

targets="vanilla append_no_lock"

for i in 32 16 8 4 2 1
do
  sudo timeout -s 9 400 ./test_zns_fs.sh $i _64 2>&1 | tee result_zns_fs_$i
  sudo timeout -s 9 400 ./test_cns.sh $i 2>&1 | tee result_cns_$i
  for target in $targets
  do
    sudo timeout -s 9 400 ./test_zns.sh $i $target 2>&1 | tee result_zns_${target}_$i
  done
  sudo timeout -s 9 400 ./test_zns_cns_fs.sh $i 2>&1 | tee result_zns_cns_fs_$i
done

