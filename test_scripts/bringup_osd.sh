sudo pkill -9 ceph
sudo cp ./ceph.conf /etc/ceph/ceph.conf

UUID=$(uuidgen)
OSD_SECRET=$(../build/bin/ceph-authtool --gen-print-key)
ID=$(echo "{\"cephx_secret\": \"$OSD_SECRET\"}" | ../build/bin/ceph osd new $UUID -i - -n client.admin -k /etc/ceph/ceph.client.admin.keyring)
DEV=/dev/nvme2n1
sudo umount $DEV
mkdir /var/lib/ceph/osd/ceph-$ID
sudo mkfs.xfs  $DEV -f
sudo mount $DEV /var/lib/ceph/osd/ceph-$ID
sudo ../build/bin/ceph-authtool --create-keyring /var/lib/ceph/osd/ceph-$ID/keyring --name osd.$ID --add-key $OSD_SECRET
sudo ../build/bin/ceph-osd -i $ID --mkfs --osd-uuid $UUID
sudo chown -R ceph:ceph /var/lib/ceph/osd/ceph-$ID
sudo ../build/bin/ceph-osd -i $ID

