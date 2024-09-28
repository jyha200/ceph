#!/bin/bash

NUM_RBD=$1

execute_remote_cmd() {
	pswd=$(cat ./pswd)
	echo "sudo sshpass -f ./pswd ssh $2@$3 \"echo $pswd | sudo -S $1\""
	sshpass -f ./pswd ssh $2@$3 "echo $pswd | sudo -S $1"
}

cat ./pswd | sudo -S umount /mnt
cat ./pswd | sudo -S ifconfig enp129s0 10.0.0.30
execute_remote_cmd "pkill -9 ceph" jyha 10.0.0.40
execute_remote_cmd "/home/jyha/mnt2/ceph/test_script/bringup_normal.sh" jyha 10.0.0.40
sshpass -f ./pswd scp jyha@10.0.0.40:/etc/ceph/ceph.client.admin.keyring /etc/ceph
sleep 5
echo `sudo cat /etc/ceph/ceph.client.admin.keyring | grep key | awk '{print $3}'`
cat ./pswd | sudo -S mount -t ceph 10.0.0.40:6789:/ /mnt/ -o name=admin,secret=`sudo cat /etc/ceph/ceph.client.admin.keyring | grep key | awk '{print $3}'`
