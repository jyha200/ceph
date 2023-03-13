#!/bin/bash

for i in 32 16 8 4 2 1
do
  #for memsize in 268435456 1073741824 2147483648 8589934592
  for memsize in 268435456 2147483648 8589934592
  do
    #for wal in false true
    for wal in true
    do
      for merge in false true
      do
  	#sudo timeout -s 9 400 ./test_zns_fs_merge.sh $i $memsize $wal $merge 2>&1 | tee result_zns_${i}_${memsize}_wal_${wal}_merge_${merge}
  	sudo timeout -s 9 400 ./test_cns_merge.sh $i $memsize $wal $merge 2>&1 | tee result_cns_${i}_${memsize}_wal_${wal}_merge_${merge}
      done
    done
  done
done

