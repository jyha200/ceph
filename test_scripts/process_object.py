#!/usr/bin/python3

import argparse
import subprocess
import os
import shutil
import random
import sys

def process():
  ceph_path = args.ceph
  files = os.listdir(args.src)
  for file in files:
    path = os.path.join(args.src, file)
    if os.path.isfile(path):
      command = ceph_path + "/rados -p " + args.pool + " put " + file + " " + path
      subprocess.call(command, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def parse_arguments():
  parser = argparse.ArgumentParser()
  parser.add_argument('--ceph', type=str, help='ceph bin path')
  parser.add_argument('--src', type=str, help='src file path')
  parser.add_argument('--pool', type=str, help='ceph pool name')
  global args
  args = parser.parse_args()

if __name__ == "__main__":
  parse_arguments()
  process()


