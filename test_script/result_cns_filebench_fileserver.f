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
1048576 bytes (1.0 MB, 1.0 MiB) copied, 0.050198 s, 20.9 MB/s
creating /var/lib/ceph/osd/ceph-0/keyring
added entity osd.0 auth(key=AQARPMZjp2tGIBAA2tMmSTiVac/7x4mgqIC9pw==)
2023-01-17T06:11:30.025+0000 7f06e051df40 -1 bluestore() _read_fsid unparsable uuid 
mkfs osd done
2023-01-17T06:11:36.865+0000 7f68397f9f40 -1 osd.0 0 log_to_monitors {default=true}
brinup_osd done
pool 'bench' created
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 1073741824 4k blocks and 134217728 inodes
Filesystem UUID: 12da7e51-77d0-48ee-89ee-29d535f4bc6f
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
0.002: File-server Version 3.0 personality successfully loaded
0.002: Populating and pre-allocating filesets
0.074: bigfileset populated: 100000 files, avg. dir. width = 20, avg. dir. depth = 3.8, 0 leafdirs, 12510.457MB total size
0.074: Removing bigfileset tree (if exists)
0.075: Pre-allocating directories in bigfileset tree
0.172: Pre-allocating files in bigfileset tree
8.742: Waiting for pre-allocation to finish (in case of a parallel pre-allocation)
8.742: Population and pre-allocation of filesets completed
8.742: Starting 1 filereader instances
9.764: Running...
69.778: Run took 60 seconds...
70.273: Per-Operation Breakdown
statfile1            942625ops    15709ops/s   0.0mb/s      0.0ms/op [0.00ms -  5.80ms]
deletefile1          942694ops    15711ops/s   0.0mb/s      0.7ms/op [0.01ms - 330.46ms]
closefile3           942756ops    15712ops/s   0.0mb/s      0.0ms/op [0.00ms -  3.96ms]
readfile1            942757ops    15712ops/s 3066.0mb/s      0.2ms/op [0.00ms - 207.54ms]
openfile2            942828ops    15713ops/s   0.0mb/s      1.8ms/op [0.00ms - 72.71ms]
closefile2           942893ops    15714ops/s   0.0mb/s      0.0ms/op [0.00ms -  5.22ms]
appendfilerand1      942897ops    15714ops/s 1229.1mb/s      0.5ms/op [0.00ms - 237.26ms]
openfile1            942949ops    15715ops/s   0.0mb/s      1.8ms/op [0.00ms - 72.94ms]
closefile1           943018ops    15716ops/s   0.0mb/s      0.0ms/op [0.00ms -  3.62ms]
wrtfile1             943022ops    15716ops/s 1964.0mb/s      0.3ms/op [0.01ms - 210.50ms]
createfile1          943074ops    15717ops/s   0.0mb/s      2.0ms/op [0.01ms - 240.18ms]
70.273: IO Summary: 10371513 ops 172846.915 ops/s 15712/31430 rd/wr 6259.0mb/s   2.4ms/op
70.273: Shutting down processes
