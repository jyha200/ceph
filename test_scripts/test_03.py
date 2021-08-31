#!/usr/bin/python3

import argparse
import subprocess
import os
import shutil
import random
import sys
import time

num_files = 1000
skew_ratio = 20
dedup_ratio = 100
chunk_size = 8192
filepath = os.path.dirname(os.path.abspath(__file__))

def execute_ceph():
  os.chdir(filepath)
  subprocess.call("sudo ./bringup_mon_osd.sh", shell=True)
  
def configure_ceph():
  os.chdir(ceph_bin_abs_path + '/../')
  subprocess.call("sudo bin/ceph osd pool create base_pool 128", shell=True)
  subprocess.call("sudo bin/ceph osd pool create chunk_pool", shell=True)
  subprocess.call("sudo bin/ceph osd pool set base_pool dedup_tier chunk_pool", shell=True)
  subprocess.call("sudo bin/ceph osd pool set base_pool dedup_chunk_algorithm fastcdc", shell=True)
  subprocess.call("sudo bin/ceph osd pool set base_pool dedup_cdc_chunk_size " + str(chunk_size), shell=True)
  subprocess.call("sudo bin/ceph osd pool set base_pool fingerprint_algorithm sha1", shell=True)
  subprocess.call("sudo bin/ceph osd pool set base_pool target_max_objects 10000", shell=True)
  subprocess.call("sudo bin/ceph osd pool set base_pool target_max_bytes 1048576000", shell=True)
  subprocess.call("sudo bin/ceph osd pool set base_pool pg_autoscale_mode off", shell=True)
  subprocess.call("sudo bin/ceph osd pool set base_pool cache_target_full_ratio .9", shell=True)

def process():
  global ceph_bin_abs_path
  ceph_bin_abs_path = os.path.abspath(args.ceph)
  print ("3. Dedup ratio and metadata according to skew\n")

  for skew in [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]:
    skew_ratio = skew

# generate test files
    print("generate test files\n")
    command = './generate_files.py -n ' + str(num_files) + ' -d ' + str(skew_ratio) + ' -r ' + str(dedup_ratio)
    subprocess.call(command, shell=True, stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)

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
        "--log", "test_03_chunk_" + str(chunk_size) + ".log"], stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)

# execute shallow crawler
    print("execute shallow crawler\n")
    command = "sudo " + ceph_bin_abs_path + "/ceph-dedup-tool --op sample-dedup --base-pool base_pool --chunk-pool chunk_pool --max-thread 1 --shallow-crawling --sampling-ratio 10 --osd-count 3 --iterative --chunk-size " + str(chunk_size)
    shallow_crawler = subprocess.Popen(command, shell=True, stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)


# put objects
    print("put object\n")
    src_dir = "test_files_" + str(num_files) + "_" + str(skew_ratio) + "_" + str(dedup_ratio)
    subprocess.call(\
        ["./process_object.py",\
        "--ceph", ceph_bin_abs_path,\
        "--src", src_dir,
        "--pool", "base_pool"])

    time.sleep(30)

    profiler_process.terminate()
    shallow_crawler.terminate()
    subprocess.call("sudo pkill -9 ceph", shell=True)

def parse_arguments():
  parser = argparse.ArgumentParser()
  parser.add_argument('--ceph', type=str, default='../build/bin/', help='ceph bin path')
  global args
  args = parser.parse_args()

if __name__ == "__main__":
  parse_arguments()
  process()

