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
1048576 bytes (1.0 MB, 1.0 MiB) copied, 0.0298468 s, 35.1 MB/s
creating /var/lib/ceph/osd/ceph-0/keyring
added entity osd.0 auth(key=AQBWOcZjfpYoNxAAuJ3yW5tvxmTdr2mC3uBPyw==)
2023-01-17T05:59:57.341+0000 7fa7a4628f40 -1 bluestore() _read_fsid unparsable uuid 

mkfs osd done
2023-01-17T06:00:14.253+0000 7f43ec1aff40 -1 osd.0 0 log_to_monitors {default=true}

brinup_osd done
pool 'bench' created
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 1073741824 4k blocks and 134217728 inodes
Filesystem UUID: 408efa49-2347-4364-9144-4d8ed1f71cf7
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
0.004: Web proxy-server Version 3.0 personality successfully loaded
0.004: Populating and pre-allocating filesets
0.053: bigfileset populated: 100000 files, avg. dir. width = 1000000, avg. dir. depth = 0.8, 0 leafdirs, 15625.000MB total size
0.053: Removing bigfileset tree (if exists)
0.054: Pre-allocating directories in bigfileset tree
0.055: Pre-allocating files in bigfileset tree
10.609: Waiting for pre-allocation to finish (in case of a parallel pre-allocation)
10.609: Population and pre-allocation of filesets completed
10.610: Starting 1 proxycache instances
11.616: Running...
71.624: Run took 60 seconds...
71.688: Per-Operation Breakdown
limit                0ops        0ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.00ms]
closefile6           1089672ops    18160ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.25ms]
readfile6            1089673ops    18160ops/s 1522.3mb/s      0.0ms/op [0.00ms - 374.63ms]
openfile6            1089679ops    18160ops/s   0.0mb/s      0.2ms/op [0.00ms - 75.84ms]
closefile5           1089685ops    18160ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.12ms]
readfile5            1089688ops    18160ops/s 1521.7mb/s      0.0ms/op [0.00ms - 389.42ms]
openfile5            1089698ops    18160ops/s   0.0mb/s      0.2ms/op [0.00ms - 10.74ms]
closefile4           1089705ops    18161ops/s   0.0mb/s      0.0ms/op [0.00ms -  7.82ms]
readfile4            1089705ops    18161ops/s 1520.2mb/s      0.0ms/op [0.00ms - 433.37ms]
openfile4            1089710ops    18161ops/s   0.0mb/s      0.2ms/op [0.00ms - 45.58ms]
closefile3           1089717ops    18161ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.15ms]
readfile3            1089718ops    18161ops/s 1522.1mb/s      0.0ms/op [0.00ms - 194.09ms]
openfile3            1089726ops    18161ops/s   0.0mb/s      0.2ms/op [0.00ms - 76.02ms]
closefile2           1089732ops    18161ops/s   0.0mb/s      0.0ms/op [0.00ms -  7.97ms]
readfile2            1089732ops    18161ops/s 1521.1mb/s      0.0ms/op [0.00ms - 311.43ms]
openfile2            1089739ops    18161ops/s   0.0mb/s      0.2ms/op [0.00ms - 74.51ms]
closefile1           1089746ops    18161ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.52ms]
appendfilerand1      1089746ops    18161ops/s 1419.6mb/s      0.1ms/op [0.01ms -  8.03ms]
createfile1          1089753ops    18161ops/s   0.0mb/s      0.3ms/op [0.02ms - 595.32ms]
deletefile1          1089629ops    18159ops/s   0.0mb/s      0.6ms/op [0.02ms - 1378.06ms]
71.688: IO Summary: 20704453 ops 345051.196 ops/s 90803/18161 rd/wr 9026.9mb/s   0.3ms/op
71.688: Shutting down processes
