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
1048576 bytes (1.0 MB, 1.0 MiB) copied, 0.0381864 s, 27.5 MB/s
creating /var/lib/ceph/osd/ceph-0/keyring
added entity osd.0 auth(key=AQA4OMZjQ0ECJBAAzCl03A3VU2xK2nTVpKXJAg==)
2023-01-17T05:55:11.046+0000 7fea47ab3f40 -1 bluestore() _read_fsid unparsable uuid 

mkfs osd done
2023-01-17T05:55:27.978+0000 7f0fa84b2f40 -1 osd.0 0 log_to_monitors {default=true}

brinup_osd done
pool 'bench' created
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 1073741824 4k blocks and 134217728 inodes
Filesystem UUID: 2ce943c9-5733-44a5-b3b6-8d6f66d41426
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
0.005: Web-server Version 3.1 personality successfully loaded
0.005: Populating and pre-allocating filesets
0.006: logfiles populated: 1 files, avg. dir. width = 20, avg. dir. depth = 0.0, 0 leafdirs, 0.002MB total size
0.006: Removing logfiles tree (if exists)
0.007: Pre-allocating directories in logfiles tree
0.008: Pre-allocating files in logfiles tree
0.080: bigfileset populated: 100000 files, avg. dir. width = 20, avg. dir. depth = 3.8, 0 leafdirs, 1563.471MB total size
0.080: Removing bigfileset tree (if exists)
0.081: Pre-allocating directories in bigfileset tree
0.180: Pre-allocating files in bigfileset tree
3.444: Waiting for pre-allocation to finish (in case of a parallel pre-allocation)
3.444: Population and pre-allocation of filesets completed
3.444: Starting 1 filereader instances
4.465: Running...
64.498: Run took 60 seconds...
68.590: Per-Operation Breakdown
appendlog            671097ops    11184ops/s 873.1mb/s     36.6ms/op [0.00ms - 969.35ms]
closefile10          670599ops    11176ops/s   0.0mb/s      0.0ms/op [0.00ms -  9.62ms]
readfile10           670600ops    11176ops/s 174.9mb/s      0.0ms/op [0.00ms - 152.68ms]
openfile10           670600ops    11176ops/s   0.0mb/s      0.2ms/op [0.00ms - 32.42ms]
closefile9           670600ops    11176ops/s   0.0mb/s      0.0ms/op [0.00ms - 13.93ms]
readfile9            670600ops    11176ops/s 174.9mb/s      0.0ms/op [0.00ms - 152.15ms]
openfile9            670600ops    11176ops/s   0.0mb/s      0.2ms/op [0.00ms - 44.02ms]
closefile8           670600ops    11176ops/s   0.0mb/s      0.0ms/op [0.00ms - 23.47ms]
readfile8            670600ops    11176ops/s 174.7mb/s      0.0ms/op [0.00ms - 205.35ms]
openfile8            670600ops    11176ops/s   0.0mb/s      0.2ms/op [0.00ms - 42.36ms]
closefile7           670600ops    11176ops/s   0.0mb/s      0.0ms/op [0.00ms - 14.96ms]
readfile7            670600ops    11176ops/s 174.9mb/s      0.0ms/op [0.00ms - 205.30ms]
openfile7            670601ops    11176ops/s   0.0mb/s      0.2ms/op [0.00ms - 48.26ms]
closefile6           670601ops    11176ops/s   0.0mb/s      0.0ms/op [0.00ms - 16.49ms]
readfile6            670601ops    11176ops/s 174.6mb/s      0.0ms/op [0.00ms - 291.29ms]
openfile6            670601ops    11176ops/s   0.0mb/s      0.2ms/op [0.00ms - 40.04ms]
closefile5           670601ops    11176ops/s   0.0mb/s      0.0ms/op [0.00ms - 26.81ms]
readfile5            670601ops    11176ops/s 174.8mb/s      0.0ms/op [0.00ms - 334.15ms]
openfile5            670601ops    11176ops/s   0.0mb/s      0.2ms/op [0.00ms - 41.62ms]
closefile4           670601ops    11176ops/s   0.0mb/s      0.0ms/op [0.00ms - 11.28ms]
readfile4            670601ops    11176ops/s 174.8mb/s      0.0ms/op [0.00ms - 287.20ms]
openfile4            670601ops    11176ops/s   0.0mb/s      0.2ms/op [0.00ms - 123.94ms]
closefile3           670601ops    11176ops/s   0.0mb/s      0.0ms/op [0.00ms - 17.30ms]
readfile3            670601ops    11176ops/s 174.9mb/s      0.0ms/op [0.00ms - 330.59ms]
openfile3            670601ops    11176ops/s   0.0mb/s      0.2ms/op [0.00ms - 124.15ms]
closefile2           670601ops    11176ops/s   0.0mb/s      0.0ms/op [0.00ms - 15.95ms]
readfile2            670601ops    11176ops/s 174.3mb/s      0.0ms/op [0.00ms - 397.99ms]
openfile2            670601ops    11176ops/s   0.0mb/s      0.2ms/op [0.00ms - 114.36ms]
closefile1           670602ops    11176ops/s   0.0mb/s      0.0ms/op [0.00ms - 21.44ms]
readfile1            670602ops    11176ops/s 174.5mb/s      0.1ms/op [0.00ms - 408.61ms]
openfile1            670603ops    11176ops/s   0.0mb/s      0.2ms/op [0.00ms - 192.78ms]
68.590: IO Summary: 20789119 ops 346453.114 ops/s 111756/11184 rd/wr 2620.4mb/s   3.5ms/op
68.590: Shutting down processes
