sudo sshpass -f ./pswd ssh jyha@10.0.0.40 "echo 1234 | sudo -S pkill -9 ceph"
[sudo] password for jyha: sudo sshpass -f ./pswd ssh jyha@10.0.0.40 "echo 1234 | sudo -S /home/jyha/mnt2/for_zns/ceph/test_script/bringup_zns.sh vanilla"
[sudo] password for jyha: brinup_mon start
creating /tmp/ceph.mon.keyring
creating /etc/ceph/ceph.client.admin.keyring
creating /etc/ceph/bootstrap-osd/ceph.keyring
importing contents of /etc/ceph/ceph.client.admin.keyring into /tmp/ceph.mon.keyring
importing contents of /etc/ceph/bootstrap-osd/ceph.keyring into /tmp/ceph.mon.keyring
/home/jyha/mnt2/for_zns/ceph/test_script/../build/bin/monmaptool: monmap file /tmp/monmap
setting min_mon_release = octopus
/home/jyha/mnt2/for_zns/ceph/test_script/../build/bin/monmaptool: set fsid to 6b6420d2-41af-4377-9a4d-de4b9dcfaf1e
/home/jyha/mnt2/for_zns/ceph/test_script/../build/bin/monmaptool: writing epoch 0 to /tmp/monmap (1 monitors)
brinup_mon done
brinup_mgr start
creating /etc/ceph/ceph.mon.keyring
added key for mgr.a
brinup_mgr done
brinup_osd start
umount: /var/lib/ceph/osd/ceph-0: not mounted.
1+0 records in
1+0 records out
1048576 bytes (1.0 MB, 1.0 MiB) copied, 0.0339606 s, 30.9 MB/s
creating /var/lib/ceph/osd/ceph-0/keyring
added entity osd.0 auth(key=AQCvOsZjSRFZFRAAiua5CwpWkuteYDVKgw+Vtw==)
2023-01-17T06:05:41.779+0000 7f5b5d777f40 -1 bluestore() _read_fsid unparsable uuid 

mkfs osd done
2023-01-17T06:05:58.711+0000 7f7cec271f40 -1 osd.0 0 log_to_monitors {default=true}

brinup_osd done
pool 'bench' created
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 1073741824 4k blocks and 134217728 inodes
Filesystem UUID: 8a0cde7a-da86-4bc7-a733-51b52b3bae80
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
	4096000, 7962624, 11239424, 20480000, 23887872, 71663616, 78675968, 
	102400000, 214990848, 512000000, 550731776, 644972544

Allocating group tables:     0/32768           done                            
Writing inode tables:     0/32768           done                            
Creating journal (262144 blocks): done
Writing superblocks and filesystem accounting information:     0/32768           done

Filebench Version 1.5-alpha3
0.000: Allocated 173MB of shared memory
0.004: File-server Version 3.0 personality successfully loaded
0.004: Populating and pre-allocating filesets
0.076: bigfileset populated: 100000 files, avg. dir. width = 20, avg. dir. depth = 3.8, 0 leafdirs, 12510.457MB total size
0.076: Removing bigfileset tree (if exists)
0.078: Pre-allocating directories in bigfileset tree
0.174: Pre-allocating files in bigfileset tree
9.248: Waiting for pre-allocation to finish (in case of a parallel pre-allocation)
9.248: Population and pre-allocation of filesets completed
9.248: Starting 1 filereader instances
10.268: Running...
70.283: Run took 60 seconds...
70.757: Per-Operation Breakdown
statfile1            671763ops    11195ops/s   0.0mb/s      0.0ms/op [0.00ms -  6.35ms]
deletefile1          671807ops    11196ops/s   0.0mb/s      6.4ms/op [0.02ms - 2097.43ms]
closefile3           671872ops    11197ops/s   0.0mb/s      0.0ms/op [0.00ms -  2.08ms]
readfile1            671873ops    11197ops/s 2145.2mb/s      1.1ms/op [0.00ms - 1524.99ms]
openfile2            671936ops    11198ops/s   0.0mb/s      1.8ms/op [0.00ms - 49.15ms]
closefile2           672001ops    11199ops/s   0.0mb/s      0.0ms/op [0.00ms -  4.71ms]
appendfilerand1      672003ops    11199ops/s 875.6mb/s      2.1ms/op [0.01ms - 1487.11ms]
openfile1            672064ops    11200ops/s   0.0mb/s      1.8ms/op [0.00ms - 37.10ms]
closefile1           672138ops    11201ops/s   0.0mb/s      0.0ms/op [0.00ms -  5.24ms]
wrtfile1             672144ops    11202ops/s 1403.5mb/s      0.5ms/op [0.01ms - 577.99ms]
createfile1          672197ops    11202ops/s   0.0mb/s      5.7ms/op [0.02ms - 1877.37ms]
70.757: IO Summary: 7391798 ops 123186.957 ops/s 11197/22401 rd/wr 4424.3mb/s   6.5ms/op
70.757: Shutting down processes
