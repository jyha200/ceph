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
dedup_ratio = 50
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
  subprocess.call("sudo bin/ceph osd pool set base_pool target_max_bytes 104857600", shell=True)
  subprocess.call("sudo bin/ceph osd pool set base_pool pg_autoscale_mode off", shell=True)
  subprocess.call("sudo bin/ceph osd pool set base_pool cache_target_full_ratio .9", shell=True)
  subprocess.call("sudo bin/rbd create test_rbd --size 100G --pool base_pool", shell=True)
#  subprocess.call("sudo bin/rbd map --pool base_pool test_rbd", shell=True)

def process():
  global ceph_bin_abs_path
  ceph_bin_abs_path = os.path.abspath(args.ceph)
  print ("1. Dedup ratio according to execution of crawler\n")

# generate test files
  if (args.skip_new_file == 0):
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
    "--log", "test_02.log"], stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)

# put objects
  print("Do fio in background\n")
  fio_log = open("test_02_fio.log", "w")
  fio_process = subprocess.Popen("sudo fio --ioengine rbd --clientname admin --pool base_pool --rbdname test_rbd --invalidate 0 --direct 1 --bsrange 4m-4m --time_based --runtime 100000 --name test --readwrite randwrite --status-interval 1 --dedupe_percentage 50",
    shell=True, stdout=fio_log)

  print("wait 30s\n")
  time.sleep(30)

# execute shallow crawler
  print("execute shallow crawler\n")
  shallow_log = open("test_02_shallow.log", "w")
  command = "sudo " + ceph_bin_abs_path + "/ceph-dedup-tool --op sample-dedup --base-pool base_pool --chunk-pool chunk_pool --max-thread 4 --shallow-crawling --sampling-ratio 10 --osd-count 3 --wakeup-period 10 --iterative --chunk-size " + str(chunk_size)
  shallow_crawler = subprocess.Popen(command, shell=True, stdout=shallow_log)

  print("wait 20s\n")
  time.sleep(30)
  shallow_crawler.kill()
  shallow_log.close()

# execute deep crawler
  print("execute deep crawler\n")
  deep_log = open("test_02_deep.log", "w")
  command = "sudo " + ceph_bin_abs_path + "/ceph-dedup-tool --op sample-dedup --base-pool base_pool --chunk-pool chunk_pool --max-thread 16 --sampling-ratio 10 --osd-count 3 --debug --chunk-size" + str(chunk_size)
  subprocess.call(command, shell=True, stdout=deep_log)
  deep_log.close()

  print("wait 30s\n")
  time.sleep(30)

  profiler_process.terminate()
  fio_process.terminate()
  fio_process.wait()
  fio_log.close()

def parse_arguments():
  parser = argparse.ArgumentParser()
  parser.add_argument('--ceph', type=str, default='../build/bin/', help='ceph bin path')
  parser.add_argument('--skip_new_file', type=int, default=0, help='skip new file')
  global args
  args = parser.parse_args()

if __name__ == "__main__":
  parse_arguments()
  process()


