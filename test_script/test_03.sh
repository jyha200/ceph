#!/bin/bash

for fs_zone in 2 4 8 16 32 64 128
do
  sudo timeout -s 9 800 ./test_zns_fs_param.sh 32 $fs_zone 32 2>&1 | tee result_zns_fs_param_32_${fs_zone}_32
done

