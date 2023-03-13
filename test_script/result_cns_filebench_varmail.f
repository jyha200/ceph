sudo sshpass -f ./pswd ssh jyha@10.0.0.40 "echo 1234 | sudo -S pkill -9 ceph"
[sudo] password for jyha: sudo sshpass -f ./pswd ssh jyha@10.0.0.40 "echo 1234 | sudo -S /home/jyha/mnt2/for_zns/ceph/test_script/bringup_cns.sh"
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
1048576 bytes (1.0 MB, 1.0 MiB) copied, 0.0309106 s, 33.9 MB/s
creating /var/lib/ceph/osd/ceph-0/keyring
added entity osd.0 auth(key=AQDlN8ZjHWZ+BRAAM7wPMqrVn2zBOTDujwFhzA==)
2023-01-17T05:53:41.551+0000 7f3febc50f40 -1 bluestore() _read_fsid unparsable uuid 
mkfs osd done
2023-01-17T05:53:48.447+0000 7f42a35ebf40 -1 osd.0 0 log_to_monitors {default=true}
brinup_osd done
pool 'bench' created
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 1073741824 4k blocks and 134217728 inodes
Filesystem UUID: b0a5e7b9-f73e-4411-bc14-c374b6d83ba1
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
	4096000, 7962624, 11239424, 20480000, 23887872, 71663616, 78675968, 
	102400000, 214990848, 512000000, 550731776, 644972544

Allocating group tables:     0/32768           done                            
Writing inode tables:     0/32768           done                            
Creating journal (262144 blocks): done
Writing superblocks and filesystem accounting information:     0/32768    2/32768           done

Filebench Version 1.5-alpha3
0.000: Allocated 173MB of shared memory
0.002: Varmail Version 3.0 personality successfully loaded
0.002: Populating and pre-allocating filesets
0.071: bigfileset populated: 100000 files, avg. dir. width = 1000000, avg. dir. depth = 0.8, 0 leafdirs, 1563.079MB total size
0.072: Removing bigfileset tree (if exists)
0.073: Pre-allocating directories in bigfileset tree
0.074: Pre-allocating files in bigfileset tree
2.765: Waiting for pre-allocation to finish (in case of a parallel pre-allocation)
2.765: Population and pre-allocation of filesets completed
2.765: Starting 1 filereader instances
3.768: Running...
63.774: Run took 60 seconds...
63.774: Per-Operation Breakdown
closefile4           67027ops     1117ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.11ms]
readfile4            67027ops     1117ops/s  54.7mb/s      0.0ms/op [0.00ms - 67.29ms]
openfile4            67027ops     1117ops/s   0.0mb/s      0.0ms/op [0.01ms -  0.35ms]
closefile3           67027ops     1117ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.17ms]
fsyncfile3           67027ops     1117ops/s   0.0mb/s      6.8ms/op [0.00ms - 75.87ms]
appendfilerand3      67037ops     1117ops/s  87.5mb/s      0.1ms/op [0.01ms - 67.31ms]
readfile3            67037ops     1117ops/s  54.3mb/s      0.0ms/op [0.00ms - 67.32ms]
openfile3            67037ops     1117ops/s   0.0mb/s      0.0ms/op [0.01ms -  0.25ms]
closefile2           67037ops     1117ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.17ms]
fsyncfile2           67037ops     1117ops/s   0.0mb/s      6.7ms/op [3.57ms - 79.40ms]
appendfilerand2      67043ops     1117ops/s  87.3mb/s      0.1ms/op [0.01ms -  6.00ms]
createfile2          67043ops     1117ops/s   0.0mb/s      0.1ms/op [0.02ms - 52.37ms]
deletefile1          67043ops     1117ops/s   0.0mb/s      0.1ms/op [0.03ms - 68.02ms]
63.775: IO Summary: 871449 ops 14522.808 ops/s 2234/2234 rd/wr 283.7mb/s   3.5ms/op
63.775: Shutting down processes
