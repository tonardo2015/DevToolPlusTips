# Difference between NFSv2, NFSv3 and NFS4 and advantage of NFSv4

Network File System (NFS), allows remote hosts to mount file systems over a network and interact with those file systems as though they are mounted locally. This enables system administrators to consolidate resources on to centralized servers on the network.

### NFSv2:
- NFS version 2 (NFSv2) is older and widely supported.  NFSv2 is not supported on RHEL7
- It can use both TCP and UDP protocol over an IP network(port 2049). But it use UDP running over an IP network to provide a stateless network connection between the client and server.
- UDP is stateless, if the server goes down unexpectedly, UDP clients continue to saturate the network with requests for the server. when a frame is lost with UDP, the entire RPC request must be re transmitted

### NFSv3:
- NFS version 3 (NFSv3) supports safe asynchronous writes and is more robust at error handling than NFSv2; it also supports 64-bit file sizes and offsets, allowing clients to access more than 2Gb of file data.
- It can use both TCP and UDP protocol over an IP network (port 2049). But it use UDP running over an IP network to provide a stateless network connection between the client and server.
- UDP is stateless, if the server goes down unexpectedly, UDP clients continue to saturate the network with requests for the server. when a frame is lost with UDP, the entire RPC request must be re transmitted.

### NFSv4:
- NFS version 4 (NFSv4) works through firewalls and on the Internet, no longer requires an rpcbind service, supports ACLs, and utilizes stateful operations.
- RHEL 6 supports NFSv2, NFSv3, and NFSv4 clients. When mounting a file system via NFS, RHEL uses NFSv4 by default, if the server supports it.
- It uses TCP protocol. With TCP, only the lost frame needs to be resent. For these reasons, TCP is the preferred protocol when connecting to an NFS server.

### Advantage of NFSv4:
- The mounting and locking protocols have been incorporated into the NFSv4 protocol
- The server also listens on the well-known TCP port 2049. As such, NFSv4 does not need to interact with rpcbind, lockd, and rpc.statd daemons. The rpc.mountd daemon is required on the NFS server to set up the exports.

---  

| No. | Parameter | NFSv3 | NFSv4 |  
| --- | --- | --- | --- |  
| 1 | State | NFSv3 is a Stateless protocol | NFSv4 is a Stateful protocol |
| 2 | Export Mounting | In NFSv3 all exports are mounted separately. | In NFSv4 all exports are mounted together as a part of pseudo-file system. |
| 3 | Protocols | In NFSv3 there are numerous protocols for different operations are collected together such as MOUNT, STATUS .. | NFSv4 comes with a single protocol with addition of OPEN and CLOSE for security auditing. | 
| 4 | No of operation / Per RPC call | One operation per RPC (Remote Procedure Call). | Multiple operation per RPC (Remote Procedure Call) |
| 5 | Delegation | No support of Delegation | Support for Delegation |
| 6 | POSIX support | Only POSIX support | Implementation of ACLs |

