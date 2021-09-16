#!/usr/bin/python3

import argparse
import subprocess
import os
import shutil
import random
import sys
import time

filepath = os.path.dirname(os.path.abspath(__file__))

def execute_ceph():
  os.chdir(filepath)
  subprocess.call("sudo ./bringup_mon_osd.sh", shell=True)

def configure_ceph():
  os.chdir(ceph_bin_abs_path + '/../')
  subprocess.call("sudo bin/ceph osd pool create base_pool 128", shell=True)
  subprocess.call("sudo bin/ceph osd pool create chunk_pool", shell=True)
  subprocess.call("sudo bin/ceph osd set noscrub", shell=True)
  subprocess.call("sudo bin/ceph osd set nodeep-scrub", shell=True)
  subprocess.call("sudo bin/ceph osd pool set base_pool dedup_tier chunk_pool", shell=True)
  subprocess.call("sudo bin/ceph osd pool set base_pool dedup_chunk_algorithm fastcdc", shell=True)
  subprocess.call("sudo bin/ceph osd pool set base_pool dedup_cdc_chunk_size " + str(chunk_size), shell=True)
  subprocess.call("sudo bin/ceph osd pool set base_pool fingerprint_algorithm sha1", shell=True)
  subprocess.call("sudo bin/ceph osd pool set base_pool target_max_objects 10000", shell=True)
  subprocess.call("sudo bin/ceph osd pool set base_pool target_max_bytes 10485760000", shell=True)
  subprocess.call("sudo bin/ceph osd pool set base_pool pg_autoscale_mode off", shell=True)
  subprocess.call("sudo bin/ceph osd pool set base_pool cache_target_full_ratio .9", shell=True)
  subprocess.call("sudo bin/ceph osd pool set base_pool cache_min_flush_age 40", shell=True)
  subprocess.call("sudo bin/ceph osd pool set base_pool cache_min_evict_age 40", shell=True)
  subprocess.call("sudo bin/rbd create test_rbd --size 100G --pool base_pool", shell=True)
#  subprocess.call("sudo bin/rbd map --pool base_pool test_rbd", shell=True)

def process():
  global ceph_bin_abs_path
  ceph_bin_abs_path = os.path.abspath(args.ceph)
  print ("4. Dedup ratio and metadata according to chunk size\n")
  global chunk_size

  for chunk in [32768, 65536, 8192, 16384]:
#  for chunk in [16384]:
    chunk_size = chunk

    print("execute ceph\n")
    execute_ceph()
    print("configure ceph\n")
    configure_ceph()

# background statistics profiling
    print("execute profiler\n")
    os.chdir(filepath)
    profiler_process = subprocess.Popen(\
        ["./accumulate_statistics.py",\
        "--ceph", ceph_bin_abs_path,\
        "--pool", "chunk_pool",\
        "--log", "test_04_chunk_" + str(chunk_size) + ".log"], stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)


    print("Do fio in background\n")
    fio_log = open("test_04_fio_chunk_"+str(chunk_size) + ".log", "w")
    fio_process = subprocess.call("sudo fio --iodepth 128 --ioengine rbd --clientname admin " +\
      "--pool base_pool --rbdname test_rbd --invalidate 0 --direct 1 --bsrange 4m-4m " +\
      "--size 4G --name test --readwrite randwrite --status-interval 1 " +\
      "--dedupe_percentage 50",
      shell=True, stdout=fio_log)

# execute shallow crawler
    print("execute shallow crawler\n")
    shallow_log = open("test_04_shallow_chunk_"+str(chunk_size) +".log","w")
    command = "sudo " + ceph_bin_abs_path + "/ceph-dedup-tool --iterative " +\
      "--op sample-dedup --base-pool base_pool --chunk-pool chunk_pool --max-thread 12 " +\
      "--shallow-crawling --sampling-ratio 100 --osd-count 3 --wakeup-period 10 " +\
      "--object-dedup-threshold 40 --chunk-size " + str(chunk_size)
    shallow_crawler = subprocess.Popen(command, shell=True, stderr=subprocess.DEVNULL, stdout=shallow_log)

    print("wait 300s\n")
    time.sleep(300)

    subprocess.call("sudo pkill -9 dedup-tool", shell=True)
    profiler_process.terminate()
    subprocess.call("sudo pkill -9 ceph", shell=True)

def parse_arguments():
  parser = argparse.ArgumentParser()
  parser.add_argument('--ceph', type=str, default='../build/bin/', help='ceph bin path')
  global args
  args = parser.parse_args()
    
if __name__ == "__main__":
  parse_arguments()
  process()

