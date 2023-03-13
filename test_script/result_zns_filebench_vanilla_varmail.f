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
1048576 bytes (1.0 MB, 1.0 MiB) copied, 0.0335433 s, 31.3 MB/s
creating /var/lib/ceph/osd/ceph-0/keyring
added entity osd.0 auth(key=AQB8N8ZjxFIJJRAA0eHH5CiC6GS7JgMaVRclKg==)
2023-01-17T05:52:03.075+0000 7f4d08500f40 -1 bluestore() _read_fsid unparsable uuid 

mkfs osd done
2023-01-17T05:52:20.023+0000 7f6768521f40 -1 osd.0 0 log_to_monitors {default=true}

brinup_osd done
pool 'bench' created
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 1073741824 4k blocks and 134217728 inodes
Filesystem UUID: 3bd4086d-30e2-4523-b847-a1ecd9d4b8a3
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
0.015: Varmail Version 3.0 personality successfully loaded
0.015: Populating and pre-allocating filesets
0.085: bigfileset populated: 100000 files, avg. dir. width = 1000000, avg. dir. depth = 0.8, 0 leafdirs, 1563.079MB total size
0.085: Removing bigfileset tree (if exists)
0.086: Pre-allocating directories in bigfileset tree
0.087: Pre-allocating files in bigfileset tree
2.803: Waiting for pre-allocation to finish (in case of a parallel pre-allocation)
2.803: Population and pre-allocation of filesets completed
2.803: Starting 1 filereader instances
3.806: Running...
63.814: Run took 60 seconds...
63.814: Per-Operation Breakdown
closefile4           7004ops      117ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.11ms]
readfile4            7004ops      117ops/s   1.8mb/s      0.3ms/op [0.01ms - 171.65ms]
openfile4            7004ops      117ops/s   0.0mb/s      0.0ms/op [0.01ms -  0.54ms]
closefile3           7004ops      117ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.15ms]
fsyncfile3           7004ops      117ops/s   0.0mb/s     65.5ms/op [12.74ms - 1015.13ms]
appendfilerand3      7010ops      117ops/s   9.1mb/s      0.2ms/op [0.01ms - 172.64ms]
readfile3            7010ops      117ops/s   1.8mb/s      0.0ms/op [0.01ms - 16.97ms]
openfile3            7010ops      117ops/s   0.0mb/s      0.0ms/op [0.01ms -  0.62ms]
closefile2           7010ops      117ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.20ms]
fsyncfile2           7010ops      117ops/s   0.0mb/s     68.8ms/op [11.74ms - 921.60ms]
appendfilerand2      7020ops      117ops/s   9.2mb/s      0.2ms/op [0.01ms - 24.90ms]
createfile2          7020ops      117ops/s   0.0mb/s      0.3ms/op [0.02ms - 392.22ms]
deletefile1          7020ops      117ops/s   0.0mb/s      1.3ms/op [0.03ms - 421.32ms]
63.814: IO Summary: 91130 ops 1518.663 ops/s 234/234 rd/wr  22.0mb/s  34.1ms/op
63.814: Shutting down processes
