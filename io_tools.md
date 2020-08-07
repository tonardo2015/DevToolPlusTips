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
