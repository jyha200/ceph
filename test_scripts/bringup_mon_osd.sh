sudo pkill -9 ceph
sudo cp ./ceph.conf /etc/ceph/ceph.conf
sudo ../build/bin/ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
sudo ../build/bin/ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'
sudo ../build/bin/ceph-authtool --create-keyring /etc/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd'
sudo ../build/bin/ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
sudo ../build/bin/ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/bootstrap-osd/ceph.keyring
sudo ../build/bin/monmaptool --clobber --create --add fg4 192.168.1.144 --fsid 6b6420d2-41af-4377-9a4d-de4b9dcfaf1e /tmp/monmap
rm -r /var/lib/ceph/mon/ceph-fg4
sudo -u ceph mkdir /var/lib/ceph/mon/ceph-fg4
sudo -u ceph ../build/bin/ceph-mon --mkfs -i fg4 --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring
sudo touch /var/lib/ceph/mon/ceph-fg4/done
sudo -u ceph ../build/bin/ceph-mon --id fg4

sudo ../build/bin/ceph-authtool --create-keyring --gen-key --name=mgr.a /etc/ceph/ceph.mon.keyring
sudo ../build/bin/ceph -i /etc/ceph/ceph.mon.keyring auth add mgr.a mon 'allow profile mgr' mds 'allow * ' osd 'allow *'
sudo ../build/bin/ceph-mgr -i a -k /etc/ceph/ceph.mon.keyring


UUID=$(uuidgen)
OSD_SECRET=$(../build/bin/ceph-authtool --gen-print-key)
ID=$(echo "{\"cephx_secret\": \"$OSD_SECRET\"}" | ../build/bin/ceph osd new $UUID -i - -n client.admin -k /etc/ceph/ceph.client.admin.keyring)
DEV=/dev/nvme0n1
sudo umount $DEV
mkdir /var/lib/ceph/osd/ceph-0
sudo mkfs.xfs  $DEV -f
sudo mount $DEV /var/lib/ceph/osd/ceph-0
sudo ../build/bin/ceph-authtool --create-keyring /var/lib/ceph/osd/ceph-0/keyring --name osd.0 --add-key $OSD_SECRET
sudo ../build/bin/ceph-osd -i 0 --mkfs --osd-uuid $UUID
sudo chown -R ceph:ceph /var/lib/ceph/osd/ceph-0
sudo ../build/bin/ceph-osd -i 0
