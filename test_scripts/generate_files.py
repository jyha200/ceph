#!/usr/bin/python3

import argparse
import subprocess
import os
import shutil
import random
import sys

file_dst = "./test_files"

def generate():
  if (args.r < args.d):
    print('skew distribution should be smaller than dedup ratio')
    return

  local_file_dst = file_dst + '_' + str(args.n) + '_' + str(args.d) + '_' + str(args.r)
  try:
    os.mkdir(local_file_dst)
  except:
    print ("files already exist, skip")
    return

  created_count = 0
  iteration = 0

  while created_count < args.n:
    file_count = args.n - created_count
    if file_count > 1000:
        file_count = 1000
    duplicate_file_count = (int)(file_count * args.r / 100)
    unique_file_count = file_count - duplicate_file_count
    skew_file_count = (int)(file_count * args.d / 100)
    command = 'fio --filesize 4k-4m --directory ' + str(local_file_dst) + \
      ' --do_verify 0 --readwrite write --group_reporting --verify_state_save 0' +\
      ' --name unique_' + str(iteration) + ' --verify md5 --nrfiles ' + str(unique_file_count) + \
      ' --name skew_' + str(iteration) + ' --verify pattern --verify_pattern 0xabcd --nrfiles ' + str(skew_file_count)
    double_dup_file_count = duplicate_file_count - skew_file_count
    for i in range(0, double_dup_file_count):
      command += " --name dup_" + str(iteration) +"_" + str(i) + " --nrfiles 1 --verify pattern --verify_pattern " + str(random.randint(0, 1000000))
    subprocess.call(command, shell=True)
    created_count = created_count + file_count
    iteration = iteration + 1

def parse_arguments():
  parser = argparse.ArgumentParser()
  parser.add_argument('-n', type=int, default=100, help='file count')
  parser.add_argument('-d', type=int, default=10, help='skew distribution (percentage)')
  parser.add_argument('-r', type=int, default=40, help='dedup ratio (percentage)')
  global args
  args = parser.parse_args()

if __name__ == "__main__":
  parse_arguments()
  generate()


