#!/bin/bash
CUR_DIR=`dirname "$0"`

echo "power off"
$CUR_DIR/power_signal.py -c 0
sleep 1
echo "pci remove"
#echo 1 > /sys/bus/pci/devices/0000\:06\:00.0/remove
echo 1 > /sys/bus/pci/devices/0000\:82\:00.0/remove
sleep 1
echo "power on"
$CUR_DIR/power_signal.py -c 1
sleep 1
echo "pci rescan"
echo 1 > /sys/bus/pci/rescan
sleep 1
