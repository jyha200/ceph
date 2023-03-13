#!/bin/bash

for group in 128 64 32 16 8 4 2 1
do
  sudo timeout -s 9 800 ./test_zns_fs_param2.sh 32 8 $group 2>&1 | tee result_zns_fs_param2_32_8_$group
done

