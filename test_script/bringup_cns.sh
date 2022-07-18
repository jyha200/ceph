#!/bin/bash

CUR_DIR=`dirname "$0"`
BIN_DIR=${CUR_DIR}/../build/bin

bringup_mon() {
  echo "brinup_mon start"
  sudo $BIN_DIR/ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
  sudo $BIN_DIR/ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'
  sudo mkdir -p /etc/ceph/bootstrap-osd
	sudo chmod 777 /etc/ceph
	sudo chmod 777 /etc/ceph/bootstrap-osd
  sudo chmod 777 /var/run
  sudo $BIN_DIR/ceph-authtool --create-keyring /etc/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd'
  sudo $BIN_DIR/ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
  sudo $BIN_DIR/ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/bootstrap-osd/ceph.keyring
  sudo $BIN_DIR/monmaptool --clobber --create --add fg4 10.0.0.40 --fsid 6b6420d2-41af-4377-9a4d-de4b9dcfaf1e /tmp/monmap
  sudo rm -r /var/lib/ceph/mon/ceph-fg4
  sudo chmod 777 /tmp/ceph.mon.keyring
  sudo mkdir /var/lib/ceph/mon/ceph-fg4
  sudo $BIN_DIR/ceph-mon --mkfs -i fg4 --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring
  sudo touch /var/lib/ceph/mon/ceph-fg4/done
  sudo $BIN_DIR/ceph-mon --id fg4
  echo "brinup_mon done"
}

bringup_mgr() {
  echo "brinup_mgr start"
  sudo $BIN_DIR/ceph-authtool --create-keyring --gen-key --name=mgr.a /etc/ceph/ceph.mon.keyring
  sudo $BIN_DIR/ceph -i /etc/ceph/ceph.mon.keyring auth add mgr.a mon 'allow profile mgr' mds 'allow * ' osd 'allow *'
  sudo $BIN_DIR/ceph-mgr -i a -k /etc/ceph/ceph.mon.keyring
  echo "brinup_mgr done"
}

bringup_osd() {
  echo "brinup_osd start"
  UUID=$(uuidgen)
  OSD_SECRET=$($BIN_DIR/ceph-authtool --gen-print-key)
  ID=$(echo "{\"cephx_secret\": \"$OSD_SECRET\"}" | $BIN_DIR/ceph osd new $UUID -i - -n client.admin -k /etc/ceph/ceph.client.admin.keyring)
  DEV=$1
  sudo umount /var/lib/ceph/osd/ceph-$ID
  sudo rm -r /var/lib/ceph/osd/ceph-$ID
  sudo nvme format -f -s1 $DEV
  mkdir /var/lib/ceph/osd/ceph-$ID
  sudo chown -R ceph:ceph /var/lib/ceph/osd/ceph-$ID
  ln -s $DEV /var/lib/ceph/osd/ceph-$ID/block
  sudo $BIN_DIR/ceph-authtool --create-keyring /var/lib/ceph/osd/ceph-$ID/keyring --name osd.$ID --add-key $OSD_SECRET
  sudo $BIN_DIR/ceph-osd -i $ID --mkfs --osd-uuid $UUID --debug-osd 1
  echo "mkfs osd done"
  sudo $BIN_DIR/ceph-osd -i $ID --debug-osd 1
  echo "brinup_osd done"
}

execute_remote_cmd() {
  pswd=$(cat ./pswd)
  echo "sudo sshpass -f ./pswd ssh $2@$3 \"echo $pswd | sudo -S $1\""
  sudo sshpass -f ./pswd ssh $2@$3 "echo $pswd | sudo -S $1"
}

sudo pkill -9 ceph
sudo mkdir -p /etc/ceph
sudo cp ${CUR_DIR}/ceph_cns.conf /etc/ceph/ceph.conf

bringup_mon
bringup_mgr
bringup_osd /dev/nvme1n1
