#!/bin/bash

targets="_64"

#for i in 32 16 8 4 2 1
for i in 16 8 4 2 1
do
  for target in $targets
  do
    sudo timeout -s 9 300 ./test_zns_fs.sh $i $target 2>&1 | tee result_zns_fs_${i}$target
  done
done

exit 0
#targets="vanilla multi_zone postpone_meta append append_multi_qd append_no_lock"


for i in 32 16 8 4 2 1
do
  for target in $targets
  do
    sudo timeout -s 9 300 ./test_zns.sh $i $target 2>&1 | tee result_zns_${target}_$i
  done
done

