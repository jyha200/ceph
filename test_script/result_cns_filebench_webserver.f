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
1048576 bytes (1.0 MB, 1.0 MiB) copied, 0.0360845 s, 29.1 MB/s
creating /var/lib/ceph/osd/ceph-0/keyring
added entity osd.0 auth(key=AQD+OMZjEzRjHBAA5A+IVDsZbqepvBF4khofpQ==)
2023-01-17T05:58:22.953+0000 7f551af08f40 -1 bluestore() _read_fsid unparsable uuid 
mkfs osd done
2023-01-17T05:58:29.849+0000 7fd66d7d4f40 -1 osd.0 0 log_to_monitors {default=true}
brinup_osd done
pool 'bench' created
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 1073741824 4k blocks and 134217728 inodes
Filesystem UUID: 4bc7ac63-1a9f-4956-a8f9-f761abb1de43
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
0.003: Web-server Version 3.1 personality successfully loaded
0.003: Populating and pre-allocating filesets
0.003: logfiles populated: 1 files, avg. dir. width = 20, avg. dir. depth = 0.0, 0 leafdirs, 0.002MB total size
0.003: Removing logfiles tree (if exists)
0.005: Pre-allocating directories in logfiles tree
0.006: Pre-allocating files in logfiles tree
0.077: bigfileset populated: 100000 files, avg. dir. width = 20, avg. dir. depth = 3.8, 0 leafdirs, 1563.471MB total size
0.077: Removing bigfileset tree (if exists)
0.078: Pre-allocating directories in bigfileset tree
0.175: Pre-allocating files in bigfileset tree
3.395: Waiting for pre-allocation to finish (in case of a parallel pre-allocation)
3.395: Population and pre-allocation of filesets completed
3.395: Starting 1 filereader instances
4.417: Running...
64.450: Run took 60 seconds...
68.436: Per-Operation Breakdown
appendlog            674233ops    11236ops/s 877.4mb/s     27.1ms/op [0.00ms - 781.78ms]
closefile10          673735ops    11228ops/s   0.0mb/s      0.0ms/op [0.00ms -  5.20ms]
readfile10           673735ops    11228ops/s 175.5mb/s      0.0ms/op [0.00ms - 122.44ms]
openfile10           673735ops    11228ops/s   0.0mb/s      0.4ms/op [0.00ms - 83.30ms]
closefile9           673735ops    11228ops/s   0.0mb/s      0.0ms/op [0.00ms -  8.56ms]
readfile9            673735ops    11228ops/s 175.6mb/s      0.0ms/op [0.00ms - 122.80ms]
openfile9            673735ops    11228ops/s   0.0mb/s      0.4ms/op [0.00ms - 69.59ms]
closefile8           673735ops    11228ops/s   0.0mb/s      0.0ms/op [0.00ms - 15.79ms]
readfile8            673735ops    11228ops/s 175.4mb/s      0.0ms/op [0.00ms - 122.88ms]
openfile8            673735ops    11228ops/s   0.0mb/s      0.4ms/op [0.00ms - 69.89ms]
closefile7           673735ops    11228ops/s   0.0mb/s      0.0ms/op [0.00ms -  7.62ms]
readfile7            673735ops    11228ops/s 175.8mb/s      0.0ms/op [0.00ms - 122.56ms]
openfile7            673736ops    11228ops/s   0.0mb/s      0.4ms/op [0.00ms - 87.81ms]
closefile6           673736ops    11228ops/s   0.0mb/s      0.0ms/op [0.00ms - 18.48ms]
readfile6            673736ops    11228ops/s 175.3mb/s      0.0ms/op [0.00ms - 120.41ms]
openfile6            673736ops    11228ops/s   0.0mb/s      0.4ms/op [0.00ms - 74.20ms]
closefile5           673736ops    11228ops/s   0.0mb/s      0.0ms/op [0.00ms - 13.72ms]
readfile5            673736ops    11228ops/s 175.6mb/s      0.0ms/op [0.00ms - 123.00ms]
openfile5            673736ops    11228ops/s   0.0mb/s      0.4ms/op [0.00ms - 82.41ms]
closefile4           673736ops    11228ops/s   0.0mb/s      0.0ms/op [0.00ms -  6.63ms]
readfile4            673736ops    11228ops/s 175.6mb/s      0.0ms/op [0.00ms - 122.03ms]
openfile4            673738ops    11228ops/s   0.0mb/s      0.4ms/op [0.00ms - 73.68ms]
closefile3           673738ops    11228ops/s   0.0mb/s      0.0ms/op [0.00ms -  8.50ms]
readfile3            673738ops    11228ops/s 175.3mb/s      0.0ms/op [0.00ms - 14.58ms]
openfile3            673738ops    11228ops/s   0.0mb/s      0.4ms/op [0.00ms - 83.27ms]
closefile2           673738ops    11228ops/s   0.0mb/s      0.0ms/op [0.00ms - 10.00ms]
readfile2            673739ops    11228ops/s 175.8mb/s      0.0ms/op [0.00ms -  9.20ms]
openfile2            673740ops    11228ops/s   0.0mb/s      0.4ms/op [0.00ms - 76.39ms]
closefile1           673740ops    11228ops/s   0.0mb/s      0.0ms/op [0.00ms -  8.23ms]
readfile1            673740ops    11228ops/s 175.6mb/s      0.0ms/op [0.00ms - 11.80ms]
openfile1            673740ops    11228ops/s   0.0mb/s      0.4ms/op [0.00ms - 78.05ms]
68.436: IO Summary: 20886331 ops 348080.095 ops/s 112281/11236 rd/wr 2632.8mb/s   2.9ms/op
68.436: Shutting down processes
