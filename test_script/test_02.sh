#!/bin/bash

targets="disable_opt enable_opt1 enable_opt2 enable_opt1_2"
for i in 10G 100G 400G 1T 4T
do
  for target in $targets
  do
    sudo timeout -s 9 400 ./test_zns1.sh 16 $target $i 2>&1 | tee result_zns_${target}_$i
  done
done
