#!/bin/bash

execute_remote_cmd() {
	pswd=$(cat ./pswd)
	echo "sudo sshpass -f ./pswd ssh $2@$3 \"echo $pswd | sudo -S $1\""
	sudo sshpass -f ./pswd ssh $2@$3 "echo $pswd | sudo -S $1"
}

execute_remote_cmd "pkill -9 ceph" jyha 10.0.0.40
execute_remote_cmd "/home/jyha/mnt2/for_zns/ceph/test_script/bringup_zns.sh $1" jyha 10.0.0.40
sudo sshpass -f ./pswd scp jyha@10.0.0.40:/etc/ceph/ceph.client.admin.keyring /etc/ceph

sudo ../build/bin/ceph osd pool create bench 32 32
sudo ../build/bin/rbd create test_1 -p bench --size 4T --image-shared
RBD_PATH=$(sudo ../build/bin/rbd map -p bench test_1)
sudo mkfs.ext4 -E nodiscard $RBD_PATH
sudo mount $RBD_PATH /mnt_tmp
sudo filebench -f /home/jyha/filebench/workloads/$2
sudo umount /mnt_tmp
sudo ../build/bin/rbd unmap $RBD_PATH
