#!/usr/bin/python3

import argparse
import subprocess
import os
import shutil
import random
import sys
import time

chunk_size = 16384
max_iteration = 2

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
  subprocess.call("sudo bin/ceph osd pool set base_pool target_max_bytes 104857600", shell=True)
  subprocess.call("sudo bin/ceph osd pool set base_pool pg_autoscale_mode off", shell=True)
  subprocess.call("sudo bin/ceph osd pool set base_pool cache_target_full_ratio .9", shell=True)
  subprocess.call("sudo bin/rbd create test_rbd --size 100G --pool base_pool", shell=True)
#  subprocess.call("sudo bin/rbd map --pool base_pool test_rbd", shell=True)

def osd_detach():
# OSD Detach
    command = "sudo " + ceph_bin_abs_path + "/ceph osd stop 0\n"
    subprocess.call(command, shell=True)
    
    print("wait 120 secs")
    time.sleep(120)

def osd_attach():
# OSD Attach
    command = "sudo " + ceph_bin_abs_path + "/ceph-osd -i 0 --no-mon-config\n"
    subprocess.call(command, shell=True)
    
    print("wait 120 secs")
    time.sleep(120)

def process():
  global ceph_bin_abs_path
  ceph_bin_abs_path = os.path.abspath(args.ceph)
  print ("6. Impact of OSD Status on IO Performance\n")

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
    "--log", "test_06.log"], stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)

# put objects
  print("Do fio in background\n")
  fio_log = open("test_06_fio.log", "w")
  fio_process = subprocess.Popen("sudo fio --ioengine rbd --clientname admin --pool base_pool --rbdname test_rbd --invalidate 0 --direct 1 --bsrange 4m-4m --time_based --runtime 100000 --name test --readwrite randrw --status-interval 1 --dedupe_percentage 50",
    shell=True, stdout=fio_log)

# execute shallow crawler
  print("execute shallow crawler\n")
  shallow_log = open("test_06_shallow.log", "w")
  command = "sudo " + ceph_bin_abs_path + "/ceph-dedup-tool --op sample-dedup --base-pool base_pool --chunk-pool chunk_pool --max-thread 4 --shallow-crawling --osd-count 3 --wakeup-period 10 --iterative --chunk-size " + str(chunk_size) 
  shallow_crawler = subprocess.Popen(command, shell=True, stdout=shallow_log)

  with open("test_06.log", "a") as file:
    file.write("+++Shallow Crawling+++\n")
  
  for iteration in range(0, max_iteration):
      osd_detach()
      with open("test_06.log", "a") as file:
          file.write("+++OSD Detached+++\n")
  
      osd_attach()
      with open("test_06.log", "a") as file:
          file.write("+++OSD Attached+++\n")
  
  shallow_crawler.kill()
  shallow_crawler.wait()
  subprocess.call("sudo pkill -9 dedup-tool", shell=True)
  shallow_log.close()
  print("execute shallow crawler done\n")

# execute deep crawler
  print("execute deep crawler\n")
  deep_log = open("test_06_deep.log", "w")
  command = "sudo " + ceph_bin_abs_path + "/ceph-dedup-tool --op sample-dedup --base-pool base_pool --chunk-pool chunk_pool --max-thread 16 --osd-count 3 --chunk-size" + str(chunk_size)
  deep_crawler = subprocess.Popen(command, shell=True, stdout=deep_log)
  
  with open("test_06.log", "a") as file:
    file.write("+++Deep Crawling+++\n")
  
  for iteration in range(0,max_iteration):
      osd_detach()
      with open("test_06.log", "a") as file:
          file.write("+++OSD_Detached+++\n")

      osd_attach()
      with open("test_06.log", "a") as file:
          file.write("+++OSD_Attached+++\n")

  deep_crawler.kill()
  deep_crawler.wait()
  subprocess.call("sudo pkill -9 dedup-tool", shell=True)
  deep_log.close()
  print("execute deep crawler done\n")

  profiler_process.terminate()
  fio_process.terminate()
  fio_process.wait()
  subprocess.call("sudo pkill -9 fio", shell=True)
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

