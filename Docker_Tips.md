### You might run into below error when pulling one docker image from docker registry:

```c
root@ubuntu:/home/patrick# docker search redis
NAME                      DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
redis                     Redis is an open source key-value store th...   2139      [OK]
sameersbn/redis                                                           32                   [OK]
torusware/speedus-redis   Always updated official Redis docker image...   29                   [OK]
bitnami/redis             Bitnami Redis Docker Image                      20                   [OK]
anapsix/redis             11MB Redis server image over AlpineLinux        6                    [OK]
williamyeh/redis          Redis image for Docker                          3                    [OK]
webhippie/redis           Docker images for redis                         3                    [OK]
clue/redis-benchmark      A minimal docker image to ease running the...   3                    [OK]
unblibraries/redis        Leverages phusion/baseimage to deploy a ba...   2                    [OK]
sin30/redis               Redis images with my own config files.          1                    [OK]
greytip/redis             redis 3.0.3                                     1                    [OK]
kampka/redis              A Redis image build from source on top of ...   1                    [OK]
servivum/redis            Redis Docker Image                              1                    [OK]
miko2u/redis              Redis                                           1                    [OK]
appelgriebsch/redis       Configurable redis container based on Alpi...   0                    [OK]
stylelabs/redis           Redis container                                 0                    [OK]
wearegenki/redis          redis                                           0                    [OK]
xataz/redis               Light redis image                               0                    [OK]
cloudposse/redis          Standalone redis service                        0                    [OK]
yfix/redis                Yfix docker redis                               0                    [OK]
nanobox/redis             Redis service for nanobox.io                    0                    [OK]
envygeeks/redis           A tiny Redis image on Alpine Linux.             0                    [OK]
trelllis/redis            Redis Replication                               0                    [OK]
khipu/redis               customized redis                                0                    [OK]
steeeveen/redis           Redis server configured for migration           0                    [OK]

root@ubuntu:/home/patrick# docker version
Client:
Version:      1.10.3
API version:  1.22 
Go version:   go1.6.1
Git commit:   20f81dd
Built:        Wed, 20 Apr 2016 14:19:16 -0700
OS/Arch:      linux/amd64

Server:
Version:      1.10.3
API version:  1.22
Go version:   go1.6.1
Git commit:   20f81dd
Built:        Wed, 20 Apr 2016 14:19:16 -0700
OS/Arch:      linux/amd64

root@ubuntu:/home/patrick# docker pull redis
Using default tag: latest
latest: Pulling from library/redis

8b87079b7a06: Downloading 36.22 MB
a3ed95caeb02: Download complete
284e33235544: Download complete
4f93af242dfb: Download complete
8c429fec161a: Download complete
77b759f85e4a: Downloading
53c576ba5ecc: Download complete
b02067e73d7e: Download complete
x509: certificate signed by unknown authority
```

The reason of this failure is that you host or VM running the docker is behind some proxy system which 
does SSL/TLS inspection, the proxy usually signs the particular server certificate with its own proxy 
root certificates. 

x509: certificate signed by unknown authority

To solve this issue, you can add your SSL and root certificate to /etc/pki/ca-trust/source/anchors/ 
and restart your docker daemon (Test on Ubuntu and CentOS, for other release, the certifcate dir 
might be different)

```c
root@ubuntu:/home/patrick/CA# ls -l /etc/pki/ca-trust/source/anchors/
total 8
-rw-r--r-- 1 root root 1266 May 22 23:24 xxx_root_ca.cer
-rw-r--r-- 1 root root 1720 May 22 23:24 xxx_ssl.cer
```
Some other solution:
```c
# docker pull some/image:tag
Trying to pull repository docker.io/some/image ... failed
Error while pulling image: 
Get https://index.docker.io/v1/repositories/some/image/images
x509: certificate signed by unknown authority
```
Not sure why docker can't just use the system cert bundle. 
Looking at the code: 

https://github.com/docker/docker/blob/1061c56a5fc126a76344ea9dca9aa5f5e75eb902/registry/registry.go#L102 
docker looks for /etc/docker/certs.d/$hostname and looks for a CA cert bundle in that directory.
So I just did this:

```c
# cd /etc/docker/certs.d
# mkdir docker.io
# cd docker.io
# ln -s /etc/pki/tls/certs/ca-bundle.crt
# ln -s /etc/pki/tls/certs/ca-bundle.trust.crt
# systemctl restart docker
```

### How to allow non-root user run docker command in ubuntu?

1. add the non-root user to docker group
```c
> sudo usermod -aG docker <username>
```
2. reboot the system
```c
> sudo reboot -nf
```

### How to push one docker image (e.g. with Harbor)

1. Create a project in Harbor, e.g. star
2. Edit the /etc/default/docker and add the docker registry as a trust site
```c
> vim /etc/default/docker
DOCKER_OPTS="--insecure-registry 10.32.190.20"
```
3. Save the configuration
4. Restart docker daemon
5. Tag the docker image
```c
root@ubuntu:/home/xxx/DevToolPlusTips# docker images
REPOSITORY                     TAG                                        IMAGE ID            CREATED             SIZE
node                           0.10                                       c305315804a5        6 days ago          632.8 MB
kibana                         latest                                     d785cb780ff7        12 days ago         297.5 MB
google/cadvisor                latest                                     4bc3588563b1        2 weeks ago         48.23 MB
redis                          latest                                     be9c5a746699        2 weeks ago         184.9 MB
10.32.190.20/mrqe/alpine       latest                                     13e1761bf172        3 weeks ago         4.797 MB
alpine                         latest                                     13e1761bf172        3 weeks ago         4.797 MB
ubuntu                         latest                                     c5f1cf30c96b        3 weeks ago         120.8 MB
nathanleclaire/logstash        43d2b4f914a192d0de221cb744dab665b07f1268   d92a7cd252a0        13 months ago       554.7 MB
nathanleclaire/logspout        43d2b4f914a192d0de221cb744dab665b07f1268   a1cc875ba511        13 months ago       263.3 MB
nathanleclaire/elasticsearch   43d2b4f914a192d0de221cb744dab665b07f1268   36cfd9d6d91a        13 months ago       531.5 MB
nathanleclaire/kibana          43d2b4f914a192d0de221cb744dab665b07f1268   0b04bfa6ff58        13 months ago       110.7 MB
root@ubuntu:/home/xxx/DevToolPlusTips# docker tag alpine 10.32.190.20/star/alpine
```
6. Push the docker image to the Harbor registry
```c
root@ubuntu:/home/xxx/DevToolPlusTips# docker push 10.32.190.20/star/alpine
The push refers to a repository [10.32.190.20/star/alpine]
8f01a53880b9: Mounted from mrqe/alpine
latest: digest: sha256:2cbf1f71c508582e40556d2dce5ab2562b60397d9ba9cd90aff96f5280ed4dac size: 506
```
