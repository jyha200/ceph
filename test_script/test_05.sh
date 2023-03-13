#!/bin/bash

targets="varmail.f webserver.f webproxy.f fileserver.f"

for workload in $targets
do
  sudo timeout -s 9 400 ./test_zns_filebench.sh fs_delta_onode $workload 2>&1 | tee result_zns_fs_filebench_$workload
#  sudo timeout -s 9 400 ./test_zns_filebench.sh vanilla $workload 2>&1 | tee result_zns_filebench_vanilla_$workload
#  sudo timeout -s 9 400 ./test_cns_filebench.sh $workload 2>&1 | tee result_cns_filebench_$workload
done

