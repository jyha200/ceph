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
1048576 bytes (1.0 MB, 1.0 MiB) copied, 0.0314436 s, 33.3 MB/s
creating /var/lib/ceph/osd/ceph-0/keyring
added entity osd.0 auth(key=AQBCOsZjJ1zbLhAAVQ4+KjmogdDV/FCh1OGJfQ==)
2023-01-17T06:03:47.251+0000 7f2f0a79df40 -1 bluestore() _read_fsid unparsable uuid 
mkfs osd done
2023-01-17T06:03:54.127+0000 7fb98cc9af40 -1 osd.0 0 log_to_monitors {default=true}
brinup_osd done
pool 'bench' created
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 1073741824 4k blocks and 134217728 inodes
Filesystem UUID: f7a615fe-95d7-4153-85bd-98afa68e6861
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
0.002: Web proxy-server Version 3.0 personality successfully loaded
0.002: Populating and pre-allocating filesets
0.051: bigfileset populated: 100000 files, avg. dir. width = 1000000, avg. dir. depth = 0.8, 0 leafdirs, 15625.000MB total size
0.051: Removing bigfileset tree (if exists)
0.052: Pre-allocating directories in bigfileset tree
0.053: Pre-allocating files in bigfileset tree
10.613: Waiting for pre-allocation to finish (in case of a parallel pre-allocation)
10.613: Population and pre-allocation of filesets completed
10.613: Starting 1 proxycache instances
11.620: Running...
71.627: Run took 60 seconds...
71.694: Per-Operation Breakdown
limit                0ops        0ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.00ms]
closefile6           1117674ops    18627ops/s   0.0mb/s      0.0ms/op [0.00ms -  1.38ms]
readfile6            1117676ops    18627ops/s 1558.2mb/s      0.0ms/op [0.00ms - 441.14ms]
openfile6            1117685ops    18627ops/s   0.0mb/s      0.2ms/op [0.00ms - 31.15ms]
closefile5           1117692ops    18627ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.24ms]
readfile5            1117693ops    18627ops/s 1557.5mb/s      0.0ms/op [0.00ms - 441.50ms]
openfile5            1117701ops    18627ops/s   0.0mb/s      0.2ms/op [0.00ms - 33.41ms]
closefile4           1117706ops    18627ops/s   0.0mb/s      0.0ms/op [0.00ms -  7.71ms]
readfile4            1117707ops    18627ops/s 1558.8mb/s      0.0ms/op [0.00ms - 441.28ms]
openfile4            1117714ops    18627ops/s   0.0mb/s      0.2ms/op [0.00ms - 30.56ms]
closefile3           1117721ops    18627ops/s   0.0mb/s      0.0ms/op [0.00ms -  1.14ms]
readfile3            1117721ops    18627ops/s 1557.7mb/s      0.0ms/op [0.00ms - 441.10ms]
openfile3            1117732ops    18628ops/s   0.0mb/s      0.2ms/op [0.00ms - 29.90ms]
closefile2           1117738ops    18628ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.97ms]
readfile2            1117738ops    18628ops/s 1557.9mb/s      0.0ms/op [0.00ms - 67.11ms]
openfile2            1117744ops    18628ops/s   0.0mb/s      0.2ms/op [0.00ms - 29.70ms]
closefile1           1117756ops    18628ops/s   0.0mb/s      0.0ms/op [0.00ms -  8.28ms]
appendfilerand1      1117758ops    18628ops/s 1454.8mb/s      0.1ms/op [0.01ms - 441.47ms]
createfile1          1117763ops    18628ops/s   0.0mb/s      0.2ms/op [0.01ms - 647.99ms]
deletefile1          1117632ops    18626ops/s   0.0mb/s      0.6ms/op [0.01ms - 1529.20ms]
71.694: IO Summary: 21236551 ops 353917.389 ops/s 93136/18628 rd/wr 9244.9mb/s   0.3ms/op
71.694: Shutting down processes
