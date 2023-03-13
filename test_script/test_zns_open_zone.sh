#!/bin/bash

NUM_RBD=16

execute_remote_cmd() {
	pswd=$(cat ./pswd)
	echo "sudo sshpass -f ./pswd ssh $2@$3 \"echo $pswd | sudo -S $1\""
	sudo sshpass -f ./pswd ssh $2@$3 "echo $pswd | sudo -S $1"
}

execute_remote_cmd "pkill -9 ceph" jyha 10.0.0.40
execute_remote_cmd "/home/jyha/mnt/my_ceph/ceph/test_script/bringup_zns_open_zone.sh $1 $2" jyha 10.0.0.40
sudo sshpass -f ./pswd scp jyha@10.0.0.40:/etc/ceph/ceph.client.admin.keyring /etc/ceph

sudo ../build/bin/ceph osd pool create bench 32 32
sudo ../build/bin/rbd create test_1 -p bench --size 4T --image-shared
FIO_CMD="sudo fio --ioengine=rbd --clientname admin --pool bench --bs 4k --eta-newline 500ms --readwrite randwrite --invalidate 0 --direct 1 --group_reporting --time_based --runtime 3m --numjobs $NUM_RBD --thread --iodepth 32 --name test --rbdname test_1"
echo $FIO_CMD
$FIO_CMD
