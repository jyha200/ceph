#!/bin/bash

NUM_RBD=$1

execute_remote_cmd() {
	pswd=$(cat ./pswd)
	echo "sudo sshpass -f ./pswd ssh $2@$3 \"echo $pswd | sudo -S $1\""
	sudo sshpass -f ./pswd ssh $2@$3 "echo $pswd | sudo -S $1"
}

execute_remote_cmd "pkill -9 ceph" jyha 10.0.0.40
execute_remote_cmd "/home/jyha/mnt2/for_zns/ceph/test_script/bringup_cns.sh $2" jyha 10.0.0.40
sudo sshpass -f ./pswd scp jyha@10.0.0.40:/etc/ceph/ceph.client.admin.keyring /etc/ceph

sudo ../build/bin/ceph osd pool create bench 32 32
sudo ../build/bin/rbd create test_1 -p bench --size 4T --image-shared

FIO_CMD="sudo fio --ioengine=rbd --clientname admin --pool bench --bs 128k --eta-newline 500ms --rw write --invalidate 0 --direct 1 --group_reporting  --size 32G --iodepth 32 --name test --rbdname test_1 --allrandrepeat 1 --do_verify 0"
echo $FIO_CMD
$FIO_CMD
FIO_CMD="sudo fio --ioengine=rbd --clientname admin --pool bench --bs 4k --eta-newline 500ms --rw randwrite --invalidate 0 --direct 1 --group_reporting --size 32G --iodepth 32 --name test --rbdname test_1 --allrandrepeat 1 --do_verify 0"
echo $FIO_CMD
$FIO_CMD
FIO_CMD="sudo fio --ioengine=rbd --clientname admin --pool bench --bs 4k --eta-newline 500ms --readwrite randread --invalidate 0 --direct 1 --group_reporting --time_based --size 1G --offset_increment 1G --runtime 30 --numjobs $NUM_RBD --thread --iodepth 32 --name test --rbdname test_1 --allrandrepeat 1"
$FIO_CMD
