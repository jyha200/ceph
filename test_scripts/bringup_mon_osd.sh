#!/bin/bash

bringup_mon() {
  echo "brinup_mon start"
  sudo ../build/bin/ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
  sudo ../build/bin/ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'
  sudo ../build/bin/ceph-authtool --create-keyring /etc/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd'
  sudo ../build/bin/ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
  sudo ../build/bin/ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/bootstrap-osd/ceph.keyring
  sudo ../build/bin/monmaptool --clobber --create --add fg4 10.0.0.40 --fsid 6b6420d2-41af-4377-9a4d-de4b9dcfaf1e /tmp/monmap
  sudo rm -r /var/lib/ceph/mon/ceph-fg4
  sudo chmod 777 /tmp/ceph.mon.keyring
  sudo -u ceph mkdir /var/lib/ceph/mon/ceph-fg4
  sudo -u ceph ../build/bin/ceph-mon --mkfs -i fg4 --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring
  sudo touch /var/lib/ceph/mon/ceph-fg4/done
  sudo -u ceph ../build/bin/ceph-mon --id fg4
  echo "brinup_mon done"
}

bringup_mgr() {
  echo "brinup_mgr start"
  sudo ../build/bin/ceph-authtool --create-keyring --gen-key --name=mgr.a /etc/ceph/ceph.mon.keyring
  sudo ../build/bin/ceph -i /etc/ceph/ceph.mon.keyring auth add mgr.a mon 'allow profile mgr' mds 'allow * ' osd 'allow *'
  sudo ../build/bin/ceph-mgr -i a -k /etc/ceph/ceph.mon.keyring
  echo "brinup_mgr done"
}

bringup_osd() {
  echo "brinup_osd start"
  UUID=$(uuidgen)
  OSD_SECRET=$(../build/bin/ceph-authtool --gen-print-key)
  ID=$(echo "{\"cephx_secret\": \"$OSD_SECRET\"}" | ../build/bin/ceph osd new $UUID -i - -n client.admin -k /etc/ceph/ceph.client.admin.keyring)
  DEV=$1
  sudo umount $DEV
  mkdir /var/lib/ceph/osd/ceph-$ID
  sudo mkfs.xfs  $DEV -f
  sudo mount $DEV /var/lib/ceph/osd/ceph-$ID
  sudo ../build/bin/ceph-authtool --create-keyring /var/lib/ceph/osd/ceph-$ID/keyring --name osd.$ID --add-key $OSD_SECRET
  sudo ../build/bin/ceph-osd -i $ID --mkfs --osd-uuid $UUID
  sudo chown -R ceph:ceph /var/lib/ceph/osd/ceph-$ID
  sudo ../build/bin/ceph-osd -i $ID --debug-osd 1
  echo "brinup_osd done"
}

execute_remote_cmd() {
  pswd=$(cat ./pswd)
  echo "sudo sshpass -f ./pswd ssh $2@$3 \"echo $pswd | sudo -S $1\""
  sudo sshpass -f ./pswd ssh $2@$3 "echo $pswd | sudo -S $1"
}

bringup_osd_remote() {
  echo "brinup_osd_remote start"
  local user=$1
  local ip=$2
  local path=$3
  sudo sshpass -f ./pswd scp /etc/ceph/ceph.client.admin.keyring $user@$ip:/etc/ceph/
  sudo sshpass -f ./pswd scp /etc/ceph/ceph.conf $user@$ip:/etc/ceph/
  local UUID=$(uuidgen)
  local OSD_SECRET=$(../build/bin/ceph-authtool --gen-print-key)
  local cmd="$path/build/bin/ceph osd new $UUID -i - -n client.admin -k /etc/ceph/ceph.client.admin.keyring"
  echo $cmd
  local ID=$(echo "{\"cephx_secret\": \"$OSD_SECRET\"}" | sshpass -f ./pswd ssh $user@$ip $cmd)
  local DEV=$4
  echo "dev: $DEV"
  cmd="umount $DEV"
  echo "$cmd $user $ip"
  execute_remote_cmd "${cmd}" $user $ip
  cmd="mkdir /var/lib/ceph/osd/ceph-$ID"
  execute_remote_cmd "${cmd}" $1 $2
  cmd="mkfs.xfs $DEV -f"
  execute_remote_cmd "${cmd}" $1 $2
  cmd="mount $DEV /var/lib/ceph/osd/ceph-$ID"
  execute_remote_cmd "${cmd}" $1 $2
  cmd="$3/build/bin/ceph-authtool --create-keyring /var/lib/ceph/osd/ceph-$ID/keyring --name osd.$ID --add-key $OSD_SECRET"
  execute_remote_cmd "${cmd}" $1 $2
  cmd="$3/build/bin/ceph-osd -i $ID --mkfs --osd-uuid $UUID"
  execute_remote_cmd "${cmd}" $1 $2
  cmd="chown -R ceph:ceph /var/lib/ceph/osd/ceph-$ID"
  execute_remote_cmd "${cmd}" $1 $2
  cmd="$3/build/bin/ceph-osd -i $ID --debug-osd 1"
  execute_remote_cmd "${cmd}" $1 $2
  echo "brinup_osd_remote done"
}

sudo ../build/bin/rbd unmap /dev/rbd0
sudo pkill -9 ceph
execute_remote_cmd "pkill -9 ceph" jyha 10.0.0.10
execute_remote_cmd "pkill -9 ceph" jyha 10.0.0.30
sudo cp ./ceph.conf /etc/ceph/ceph.conf

bringup_mon
bringup_mgr
bringup_osd /dev/nvme1n1
bringup_osd_remote jyha 10.0.0.10 /home/cephlab/mnt/jyha/ceph/ /dev/nvme0n1
bringup_osd_remote jyha 10.0.0.30 /home/jyha/ceph/ /dev/nvme1n1
