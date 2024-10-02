#!/bin/bash

CUR_DIR=`dirname "$0"`
BIN_DIR=${CUR_DIR}/../build/bin

recreate_osd() {
  sudo $BIN_DIR/ceph-osd -i 0 --debug-osd 1
  echo "brinup_osd done"
}

wait_dev() {
    DEV=$1
    k=0
    while [ ! -e $DEV ]; do
      if [ $k -eq 30 ]; then
        echo "cannot find $DEV need reboot"
        exit 1
#        reboot
      fi
      sleep 1;
      k=$(expr $k + 1)
    done
}

sudo umount /mnt
sudo $CUR_DIR/pcie_spo.sh
wait_dev /dev/nvme0n1
sudo mount /dev/nvme0n1 /mnt
recreate_osd
