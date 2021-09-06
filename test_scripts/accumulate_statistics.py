#!/usr/bin/python3

import argparse
import subprocess
import os
import shutil
import random
import sys
import time
import threading

def get_statistics():
  ceph_path = args.ceph
  command = ceph_path + "/ceph osd df"
  subprocess.call(command, shell=True, stdout=log)
  log.flush()
  log.write('\n')
  log.flush()
  command = ceph_path + "/rados " + " df"
  subprocess.call(command, shell=True, stdout=log)

  threading.Timer(5, get_statistics).start()

def process():
  global log
  log = open(args.log, "w")
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


