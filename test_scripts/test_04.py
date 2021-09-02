#!/usr/bin/python3

import argparse
import subprocess
import os
import shutil
import random
import sys
import time

num_files = 100
skew_ratio = 40
dedup_ratio = 50
chunk_size = 8192
filepath = os.path.dirname(os.path.abspath(__file__))

def execute_ceph():
  os.chdir(filepath)
  subprocess.call("sudo ./bringup_mon_osd.sh", shell=True)
  
def wait():
    # wait until all data flushed
    print("wait all object flushed\n")
    time.sleep(100)
  #  return 
    
    while True:
        proc = subprocess.Popen('sudo ../build/bin/rados df | awk \'{if($1==\"base_pool\") print $2}\'', stdout=subprocess.PIPE, shell=True)
        msg = proc.stdout.read()
        proc.wait()
        if int(msg) == 0:
            break


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

def process():
  global ceph_bin_abs_path
  ceph_bin_abs_path = os.path.abspath(args.ceph)
  print ("4. Dedup ratio and metadata according to chunk size\n")

# generate test files
  if (args.skip_new_file == 0):
    print("generate test files\n")
    command = './generate_files.py -n ' + str(num_files) + ' -d ' + str(skew_ratio) + ' -r ' + str(dedup_ratio)
    subprocess.call(command, shell=True, stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)

  for chunk in [4096, 8192, 16384, 32768, 65536]:
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

# execute shallow crawler
    print("execute shallow crawler\n")
    command = "sudo " + ceph_bin_abs_path + "/ceph-dedup-tool --op sample-dedup --base-pool base_pool --chunk-pool chunk_pool --max-thread 4 --shallow-crawling --sampling-ratio 10 --osd-count 3 --wakeup-period 10 --iterative --chunk-size " + str(chunk_size)
#    shallow_crawler = subprocess.Popen(command, shell=True, stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)

    print("Do fio in background\n")
    fio_log = open("test_04_fio_chunk_"+str(chunk_size) + ".log", "w")
    fio_process = subprocess.Popen("sudo fio --ioengine rbd --clientname admin --pool base_pool --rbdname test_rbd --invalidate 0 --direct 1 --bsrange 4m-4m --time_based --runtime 100000 --name test --readwrite randwrite --status-interval 1 --dedupe_percentage 50",
      shell=True, stdout=fio_log)

    time.sleep(200)

    profiler_process.terminate()
    shallow_crawler.kill()
    shallow_crawler.wait()
    fio_process.terminate()
    fio_process.wait()
    subprocess.call("sudo pkill -9 ceph", shell=True)

def parse_arguments():
  parser = argparse.ArgumentParser()
  parser.add_argument('--ceph', type=str, default='../build/bin/', help='ceph bin path')
  parser.add_argument('--skip_new_file', type=int, default=0, help='skip new file')
  global args
  args = parser.parse_args()
    
if __name__ == "__main__":
  parse_arguments()
  process()

