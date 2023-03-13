#!/bin/bash

NUM_RBD=$1

execute_remote_cmd() {
	pswd=$(cat ./pswd)
	echo "sudo sshpass -f ./pswd ssh $2@$3 \"echo $pswd | sudo -S $1\""
	sudo sshpass -f ./pswd ssh $2@$3 "echo $pswd | sudo -S $1"
}

execute_remote_cmd "pkill -9 ceph" jyha 10.0.0.40
execute_remote_cmd "/home/jyha/mnt/my_ceph/ceph/test_script/bringup_zns_cns_fs.sh" jyha 10.0.0.40
sudo sshpass -f ./pswd scp jyha@10.0.0.40:/etc/ceph/ceph.client.admin.keyring /etc/ceph

sudo ../build/bin/ceph osd pool create bench 32 32
RBDS=$(seq 1 $NUM_RBD)
sudo ../build/bin/rbd create test_1 -p bench --size $2 --image-shared
FIO_CMD="sudo fio --ioengine=rbd --clientname admin --pool bench --bs 4k --eta-interval 1 --eta-newline 1 --readwrite randwrite --invalidate 0 --direct 1 --group_reporting --numjobs $NUM_RBD --thread --iodepth 32 --name job --rbdname test_1 --time_based --runtime 3m"
echo $FIO_CMD
$FIO_CMD
