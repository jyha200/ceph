#!/bin/bash


targets="fs_open_zone per_zone_lock_fs_open_zone"
for i in 33 34 35 36 37 40 48
do
  for target in $targets
  do
    sudo timeout -s 9 400 ./test_zns_open_zone.sh $target $i 2>&1 | tee result_zns_open_zone_${target}_$i
  done
done

