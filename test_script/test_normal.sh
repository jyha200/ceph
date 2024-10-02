#!/bin/bash

NUM_RBD=$1
use_watchdog="rlw"
#use_watchdog="false"
TIMEOUT_MS=0
BDEV_NAME=nvme0
WATCHDOG=/home/jyha/mnt2/linux_rlw/linux/drivers/nvme/host/nvme-watchdog.ko

execute_remote_cmd() {
	pswd=$(cat ./pswd)
	echo "sudo sshpass -f ./pswd ssh $2@$3 \"echo $pswd | sudo -S $1\""
	sshpass -f ./pswd ssh $2@$3 "echo $pswd | sudo -S $1"
}

do_fio() {
SIZE=163840
j=8
SIZE_PER_JOB=$(expr $SIZE / $j)

cat ./pswd | sudo -S timeout -k 9 300 fio --rw randwrite --bs 4k --directory /mnt --ioengine psync --verify crc32c --size ${SIZE_PER_JOB}m --numjobs ${j} --thread --group_reporting --do_verify 0 --allrandrepeat 1 --continue_on_error none --name test --time_based --runtime 100 --eta-newline 500ms&
PID=$!
sleep 2
execute_remote_cmd "/home/jyha/mnt2/ceph/test_script/power_signal.py -c 0" jyha 10.0.0.40
wait $PID
#echo 1234 | sudo -S timeout -k 9 300 wait $PID
}

do_filebench() {
workload="fileserver.f"

echo 0 > /proc/sys/kernel/randomize_va_space
cat ./pswd | sudo -S timeout -k 9 300 filebench -f /home/jyha/filebench/workloads/$workload
PID=$!
sleep 2
execute_remote_cmd "/home/jyha/mnt2/ceph/test_script/power_signal.py -c 0" jyha 10.0.0.40
wait $PID
}

cat ./pswd | sudo -S umount /mnt
execute_remote_cmd "pkill -9 ceph" jyha 10.0.0.40
execute_remote_cmd "pkill -9 ceph" jyha 10.0.0.30
execute_remote_cmd "rmmod $WATCHDOG" jyha 10.0.0.40
#execute_remote_cmd "/home/jyha/mnt2/ceph/test_script/bringup_normal_mon_mgr_osd.sh" jyha 10.0.0.40
execute_remote_cmd "/home/jyha/mnt2/ceph/test_script/bringup_fs_mon_mgr_osd.sh" jyha 10.0.0.40
sshpass -f ./pswd scp jyha@10.0.0.40:/etc/ceph/ceph.client.admin.keyring /etc/ceph
sshpass -f ./pswd scp /etc/ceph/ceph.client.admin.keyring jyha@10.0.0.30:/etc/ceph/
execute_remote_cmd "/home/jyha/ceph/ceph/test_script/bringup_normal_mds.sh" jyha 10.0.0.30
echo `sudo cat /etc/ceph/ceph.client.admin.keyring | grep key | awk '{print $3}'`

../build/bin/ceph osd pool create cephfs_data
../build/bin/ceph osd pool create cephfs_meta
../build/bin/ceph fs new cephfs.a cephfs_data cephfs_meta
sleep 1
cat ./pswd | sudo -S mount -t ceph 10.0.0.40:6789:/ /mnt/ -o name=admin,secret=`sudo cat /etc/ceph/ceph.client.admin.keyring | grep key | awk '{print $3}'`

if [ "$use_watchdog" != "false" ]; then
  if [ "$use_watchdog" = "no_rl" ]; then
    TIMEOUT_MS=84
  fi
  execute_remote_cmd "insmod $WATCHDOG device_list=$BDEV_NAME timeout_ms=$TIMEOUT_MS polling_duration_ms=64 max_kiops=180" jyha 10.0.0.40
fi

#do_fio
do_filebench

execute_remote_cmd "/home/jyha/mnt2/ceph/test_script/recreate_osd.sh" jyha 10.0.0.40
sudo umount /mnt
execute_remote_cmd "rmmod $WATCHDOG" jyha 10.0.0.40
