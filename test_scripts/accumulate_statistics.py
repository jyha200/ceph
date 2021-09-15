#!/usr/bin/python3

import argparse
import subprocess
import os
import shutil
import random
import sys
import time
import threading

osd_count = 3

def get_statistics():
  start = time.time()
  ceph_path = args.ceph
  subprocess.call("date",shell=True, stdout=log)
  for osd in range(osd_count):
    command = ceph_path + "/ceph tell osd." + str(osd) +" compact"
    subprocess.call(command, shell=True)
  command = ceph_path + "/ceph osd df"
  subprocess.call(command, shell=True, stdout=log)
  log.flush()
  log.write('\n')
  log.flush()

  command = ceph_path + "/rados " + " df"
  subprocess.call(command, shell=True, stdout=log)
  end = time.time()
  elapsed = end - start
  sleep_time = args.duration - elapsed
  if sleep_time > 0:
    time.sleep(sleep_time)
#  threading.Timer(5, get_statistics).start()

def process():
  global log
  log = open(args.log, "w")
  while True:
    get_statistics()
  

def parse_arguments():
  parser = argparse.ArgumentParser()
  parser.add_argument('--ceph', type=str, help='ceph bin path')
  parser.add_argument('--pool', type=str, help='target pool')
  parser.add_argument('--log', type=str, help='log file path')
  parser.add_argument('--duration', type=int, default=5, help='profile duration(s)')
  parser.add_argument('--runtime', type=int, default=0, help='runtime(s), 0 is infinite')
  global args
  args = parser.parse_args()

if __name__ == "__main__":
  parse_arguments()
  process()
#  log.close()


