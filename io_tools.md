# I/O tools


## FIO  
- #### Read Test  

```
fio --name=randread --ioengine=libaio --iodepth=16 --rw=randread --bs=4k --direct=0 --size=512M --numjobs=4 --runtime=240 --group_reporting
```
---
- #### Writes a total 2GB files `[4 jobs x 512 MB = 2GB]` running 4 processes at a time:
```
fio --name=randwrite --ioengine=libaio --iodepth=1 --rw=randwrite --bs=4k --direct=0 --size=512M --numjobs=4 --runtime=240 --group_reporting
```
- #### Read Write Performance Test
```
fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=random_read_write.fio --bs=4k --iodepth=64 --size=4G --readwrite=randrw --rwmixread=75
```
- #### Sequential Reads 
    - Async mode   
    - 8K block size   
    - Direct IO   
    - 100% Reads  
```
fio --name=seqread --rw=read --direct=1 --ioengine=libaio --bs=8k --numjobs=8 --size=1G --runtime=600  --group_reporting
```

- #### Sequential Writes 

    - Async mode  
    - 32K block size  
    - Direct IO   
    - 100% Writes  

```
fio --name=seqwrite --rw=write --direct=1 --ioengine=libaio --bs=32k --numjobs=4 --size=2G --runtime=600 --group_reporting
```
- #### Random Reads 
    - Async mode   
    - 8K block size   
    - Direct IO   
    - 100% Reads  

```
fio --name=randread --rw=randread --direct=1 --ioengine=libaio --bs=8k --numjobs=16 --size=1G --runtime=600 --group_reporting
```
- #### Random Writes 
    - Async mode  
    - 64K block size   
    - Direct IO  
    - 100% Writes  
```
fio --name=randwrite --rw=randwrite --direct=1 --ioengine=libaio --bs=64k --numjobs=8 --size=512m --runtime=600 --group_reporting
```
- #### Random Read/Writes 
    - Async mode  
    - 16K block size   
    - Direct IO  
    - 90% Reads/10% Writes  
```
fio --name=randrw --rw=randrw --direct=1 --ioengine=libaio --bs=16k --numjobs=8 --rwmixread=90 --size=1G --runtime=600 --group_reporting
```

> Creates 8 files (numjobs=8), each with size 512MB (size) at 64K block size (bs=64k) and will perform random read/write (rw=randrw) with the mixed workload of 70% reads and 30% writes.
 The job will run for full 5 minutes (runtime=300 & time_based) even if the files were created and read/written.

```
fio --name=randrw --ioengine=libaio --iodepth=1 --rw=randrw --bs=64k --direct=1 --size=512m --numjobs=8 --runtime=300 --group_reporting --time_based --rwmixread=70
```

> Compare disk performance with a simple 3:1 4K read/write. The test creates a 4 GB file and perform 4KB reads and writes using a (75%/25%) split within the file, with 64 operations running at a time. The 3:1 ratio represents a typical database.
```
fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=test --bs=4k --iodepth=64 --size=4G --readwrite=randrw --rwmixread=75
```

- #### Random read performance
```
fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=test --bs=4k --iodepth=64 --size=4G --readwrite=randread
```

- #### Random write performance
```
fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=test --bs=4k --iodepth=64 --size=4G --readwrite=randwrite
```

---

## dd
- #### Write 1GB (64k * 16k) data to file test with block size 64k
```
dd if=/dev/zero of=test bs=64k count=16k conv=fdatasync
```

> **dd's cons**:
>- This is a single-threaded, sequential-write test. If you are running the typical web+database server on your VPS, the number is meaningless because typical services do not do long-running sequential writes.
>- The amount of data written (1GB) is small; and hence can be strongly influenced by caching on the host server, or the host's RAID controller. (The conv=fdatasync only applies to the VPS, not the host).
>- It executes for a very short period of time; just a few seconds on faster I/O subsystems. This isn't enough to get a consistant result.
>- There's no read performance testing at all.

---
## ioping - simple disk I/O latency monitoring tool
`ioping` allows you to see if storage is performing as expected, or if there are some performance issues that can express themselves as general slowness and as latency spikes for some requests. These latency issues are not always easily visible in historical graphs that are plotting averages.

> What Storage Latencies Matter Most for MySQL ?

Before we look at using `ioping` to measure them, what I/O latencies matter most for MySQL?      

The first is Sequential Synchronous writes to the **Innodb Log** File. Any stalls in these will stall write transaction commits, and all following transactions commits as well. Even though MySQL supports Group Commit, only one such Group Commit operation can process at any moment in time.

The second is Random Reads, which are submitted through Asynchronous IO, typically using a DirectIO operation. This is critical for serving your general I/O intensive queries: Selects, Updates, Deletes and most likely Inserts will relay them on fetching such data from storage. Such fetches are latency sensitive: since they must be completed during query execution, they can’t be delayed.

You may ask, "What is about Random Writes?"  Random (non-sequential) writes happen in the background as InnoDB flushes dirty pages from its buffer pool. While it is important, storage has enough throughput to keep up with the workload. It is not latency sensitive since it is not in any query execution critical path.

One more access pattern important for MySQL performance is writing binary logs (especially with sync_binlog=1). This is different from writing to the `InnoDB log` file, because writes go to the end of file and cause the file to grow. As such, it requires constant updates to the file system metadata. Unfortunately, it doesn’t look like ioping supports this I/O pattern yet.

- #### Simulating MySQL IO Patterns with ioping
> To simulate writing to the log file, we will use a medium-sized file (64M) and sequential 4K size writes to assess the latency: 
```
ioping -S64M  -L -s4k -W -c 10 .
```

- #### For Read IO testing, we better use 16K IOs (InnoDB default page size) that are submitted through Asynchronous IO in O_DIRECT Mode  
```
ioping -A -D -s16k  -c 10 .
```
- #### Using  ioping for Monitoring
```
ioping -k -B -S64M  -L -s4k -W -c 100 -i 0.1  .
```
> For monitoring you might want to look at offsets 6,7,8 — which specify avg, max and stdev statistics for IO requests measured in nanoseconds

```
ioping -p 100 -c 200 -i 0 -q .
99 10970974 9024 36961531 90437 110818 358872 30756 100 12516420
100 9573265 10446 42785821 86849 95733 154609 10548 100 10649035
(1) (2) (3) (4) (5) (6) (7) (8) (9) (10)

(1) count of requests in statistics
(2) running time (nanoseconds)
(3) requests per second (iops)
(4) transfer speed (bytes per second)
(5) minimal request time (nanoseconds)
(6) average request time (nanoseconds)
(7) maximum request time (nanoseconds)
(8) request time standard deviation (nanoseconds)
(9) total requests (including warmup, too slow or too fast)
(10) total running time (nanoseconds)
```

- [ioping reference](https://manpages.debian.org/testing/ioping/ioping.1.en.html)


## I/O with Multipath(SLES)

```
~# rpm -q open-iscsi
open-iscsi-2.0.873-20.4.x86_64

~# rpm -q multipath-tools
multipath-tools-0.5.0-30.1.x86_64

~# cat /etc/multipath.conf
defaults {
    verbosity 2
    no_path_retry "fail"
    user_friendly_names "yes"
#    find_multipaths "no"
    polling_interval 10
    path_checker tur
    max_fds 8192
    flush_on_last_del yes
    force_sync yes
}

blacklist {
#       devnode ".*"
    devnode "^(ram|raw|loop|fd|md|sr|scd|st)[0-9]*"
    devnode "^hd[a-z]"
    device {
        vendor "VMware"
        product "Virtual disk"
    }
}

devices {
    device {
        vendor "DGC"
        product "VRAID"
        path_grouping_policy "group_by_prio 1"
        path_selector "queue-length 0"
        prio alua
        prio_args alua
        detect_prio yes
        hardware_handler "1 alua"
        failback followover
        dev_loss_tmo 60
    }
}

~# sudo multipath -v2 -d

~# service multipathd status
multipathd.service - Device-Mapper Multipath Device Controller
   Loaded: loaded (/usr/lib/systemd/system/multipathd.service; enabled)
   Active: active (running) since Mon 2020-06-08 04:24:31 EDT; 2 months 10 days ago
  Process: 478 ExecStartPre=/sbin/modprobe dm-multipath (code=exited, status=0/SUCCESS)
 Main PID: 512 (multipathd)
   Status: "running"
   CGroup: /system.slice/multipathd.service
           └─512 /sbin/multipathd -d -s

##To Discovery iSCSI Target, try below commend
# iscsiadm -m discoverydb -p <portal ip> -t st -D
# iscsiadm -m discoverydb -p 10.228.44.62 -t st -D

##To Login iSCSI Taret
# iscsiadm -m node -p <spa portal ip> -T <target port iqn> -l
# iscsiadm -m node -p 10.228.44.62 -T iqn.1992-04.com.emc:cx.fcnch0972c2c3b.a1 -l
# iscsiadm -m node -p 10.228.44.63 -T iqn.1992-04.com.emc:cx.fcnch0972c2c3b.b1 -l

##To Logout iSCSI Target
# iscsiadm -m node -p <spa portal ip> -T <target port iqn> -u
# iscsiadm -m node -T iqn.1992-04.com.emc:cx.fcnch0972c2c3b.a1 -p 10.228.44.62 -u

##To Delete iSCSI sessions
# iscsiadm -m node -o delete -T iqn.1992-04.com.emc:cx.fcnch0972c2c3b.a1 --portal 10.228.44.62:3260

# Allocate LUN to Host from array side

##Rescan Disk
# iscsiadm -m session --rescan
or
# iscsiadm -m session -R

##List the devices
# multipath -ll
mpathe (3600601607dd30a00afaa3b5faa581574) dm-4 DGC,VRAID
size=5.0G features='1 queue_if_no_path' hwhandler='1 alua' wp=rw
|-+- policy='queue-length 0' prio=50 status=active
| `- 4:0:0:4 sdl 8:176 active ready running
`-+- policy='queue-length 0' prio=10 status=enabled
  `- 5:0:0:4 sdk 8:160 active ready running
mpathd (3600601607dd30a00aeaa3b5f08d56f3f) dm-3 DGC,VRAID
size=5.0G features='1 queue_if_no_path' hwhandler='1 alua' wp=rw
|-+- policy='queue-length 0' prio=50 status=active
| `- 5:0:0:3 sdi 8:128 active ready running
`-+- policy='queue-length 0' prio=10 status=enabled
  `- 4:0:0:3 sdj 8:144 active ready running
mpathc (3600601607dd30a00aeaa3b5fa29d0a47) dm-2 DGC,VRAID
size=5.0G features='1 queue_if_no_path' hwhandler='1 alua' wp=rw
|-+- policy='queue-length 0' prio=50 status=active
| `- 4:0:0:2 sdh 8:112 active ready running
`-+- policy='queue-length 0' prio=10 status=enabled
  `- 5:0:0:2 sdg 8:96  active ready running
mpathb (3600601607dd30a00adaa3b5f7d6cdd27) dm-1 DGC,VRAID
size=5.0G features='1 queue_if_no_path' hwhandler='1 alua' wp=rw
|-+- policy='queue-length 0' prio=50 status=active
| `- 5:0:0:1 sde 8:64  active ready running
`-+- policy='queue-length 0' prio=10 status=enabled
  `- 4:0:0:1 sdf 8:80  active ready running

# lsscsi
[0:0:0:0]    disk    VMware   Virtual disk     1.0   /dev/sda
[0:0:1:0]    disk    VMware   Virtual disk     1.0   /dev/sdb
[2:0:0:0]    cd/dvd  NECVMWar VMware IDE CDR10 1.00  /dev/sr0
[4:0:0:0]    disk    DGC      LUNZ             5100  /dev/sdc
[4:0:0:1]    disk    DGC      VRAID            5100  /dev/sdf
[4:0:0:2]    disk    DGC      VRAID            5100  /dev/sdh
[4:0:0:3]    disk    DGC      VRAID            5100  /dev/sdj
[4:0:0:4]    disk    DGC      VRAID            5100  /dev/sdl
[5:0:0:0]    disk    DGC      LUNZ             5100  /dev/sdd
[5:0:0:1]    disk    DGC      VRAID            5100  /dev/sde
[5:0:0:2]    disk    DGC      VRAID            5100  /dev/sdg
[5:0:0:3]    disk    DGC      VRAID            5100  /dev/sdi
[5:0:0:4]    disk    DGC      VRAID            5100  /dev/sdk

# ls /dev/sd*
/dev/sda  /dev/sda1  /dev/sdb  /dev/sdb1  /dev/sdc  /dev/sdd  /dev/sde  /dev/sdf  /dev/sdg  /dev/sdh  /dev/sdi  /dev/sdj  /dev/sdk  /dev/sdl

# lsblk
NAME                         MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
fd0                            2:0    1    4K  0 disk
sda                            8:0    0   50G  0 disk
└─sda1                         8:1    0   50G  0 part  /
sdb                            8:16   0  300G  0 disk
└─sdb1                         8:17   0  300G  0 part  /user_data_disk
sdc                            8:32   0    5G  0 disk
sdd                            8:48   0    5G  0 disk
sde                            8:64   0    5G  0 disk
└─mpathb                     254:1    0    5G  0 mpath
sdf                            8:80   0    5G  0 disk
└─mpathb                     254:1    0    5G  0 mpath
sdg                            8:96   0    5G  0 disk
└─mpathc                     254:2    0    5G  0 mpath
sdh                            8:112  0    5G  0 disk
└─mpathc                     254:2    0    5G  0 mpath
sdi                            8:128  0    5G  0 disk
└─mpathd                     254:3    0    5G  0 mpath
sdj                            8:144  0    5G  0 disk
└─mpathd                     254:3    0    5G  0 mpath
sdk                            8:160  0    5G  0 disk
└─mpathe                     254:4    0    5G  0 mpath
sdl                            8:176  0    5G  0 disk
└─mpathe                     254:4    0    5G  0 mpath
sr0                           11:0    1 1024M  0 rom
loop0                          7:0    0  100G  0 loop
└─docker-8:17-272252041-pool 254:0    0  100G  0 dm
loop1                          7:1    0    2G  0 loop
└─docker-8:17-272252041-pool 254:0    0  100G  0 dm

```
- [SLES MPIO Reference](https://www.suse.com/support/kb/doc/?id=000016326)
- [Managing Multipath I/O](https://documentation.suse.com/sles/15-SP1/html/SLES-all/cha-multipath.html)

> - LUNs are not seen by the driver
> `lsscsi` can be used to check whether the SCSI devices are seen correctly by the OS. When the LUNs are not seen by the HBA driver, check the zoning setup of the SAN. In particular, check whether LUN masking is active and whether the LUNs are correctly assigned to the server.

> - LUNs are seen by the driver, but there are no corresponding block devices  
> When LUNs are seen by the HBA driver, but not as block devices, additional kernel parameters are needed to change the SCSI device scanning behavior, e.g. to indicate that LUNs are not numbered consecutively.
