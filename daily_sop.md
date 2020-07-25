# Tips for common operation in Linux

### NFS Share
```
sudo apt update
sudo apt install nfs-common
sudo yum install nfs-utils
sudo mkdir /var/backups
sudo mount -t nfs 10.10.0.10:/backups /var/backups
```
To verify that the remote NFS volume is successfully mounted use either the `mount` or `df -h` command

```
sudo nano /etc/fstab
---
/etc/fstab
# <file system>     <dir>       <type>   <options>   <dump>	<pass>
10.10.0.10:/backups /var/backups  nfs      defaults    0       0
```

### mount the NFS
```
mount /var/backups
mount 10.10.0.10:/backups
```

The `umount` command will fail to detach the share when the mounted volume is in use. To find out which processes are accessing the NFS share, use the `fuser` command:
```
fuser -m MOUNT_POINT
```
If the remote NFS system is unreachable, use the -f (--force) option to force an unmount.
```
umount -f MOUNT_POINT
```

## Command to get nth line of STDOUT

```
ls -l | sed -n 2p
ls -l | sed -n -e '2{p;q}'

#For a range of lines
ls -l | sed -n 2,4p

#For several ranges of lines
ls -l | sed -n -e 2,4p -e 20,30p
ls -l | sed -n -e '2,4p;20,30p'

ls -al | awk 'NR==2'

# print line number 52
awk 'NR==52'
awk 'NR==52 {print;exit}' # more efficient on large files

find / | awk NR==3
find / | awk 'NR==3 {print $0; exit}'

# delete all the lines that aren't the second one
ls -l | sed '2 ! d' 

# print 'odd' lines 1,3,5...
ls -l | awk '0==(NR+1)%2'
# print 'even' lines 2,4,6...
ls -l | awk '0==(NR)%2'

ls -l | (read; head -n1)
``` 

## Packet capturing

> Capture packet from specific host

```
tcpdump -nnvvS src 10.5.2.3 and dst port 3389
```
https://danielmiessler.com/study/tcpdump/  
https://bencane.com/2014/10/13/quick-and-practical-reference-for-tcpdump/


## How to trim the white spaces from bash shell
```
echo $variable | xargs echo -n
```
> The `xargs` removes all the delimiters from the string. By default it uses the space as delimiter. The `echo -n` will remove the end of line >>> [More info](https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable)

## How to record command line operation
> We can leverage `asciinema` to record and play command line operation.  
- #### Installation  
```
$ sudo pip3 install asciinema 
```
- #### Usage: Record  
```
$ asciinema rec demo.cast
```
- #### Usage: Play  
```
$ asciinema play demo.cast
```
- #### Usage: Upload  
```
$ asciinema upload <filename>
```  
- #### How to use recorded screen in web
> Use with stand-alone player on your website
Download asciinema player from [player's releases page](https://github.com/asciinema/asciinema-player/releases) (you only need `.js` and `.css` file), then use it like this:
```
<html>
<head>
  <link rel="stylesheet" type="text/css" href="/asciinema-player.css" />
</head>
<body>
  <asciinema-player src="/168763.json" cols="80" rows="24"></asciinema-player>
  ...
  <script src="/asciinema-player.js"></script>
</body>
</html>
```
- More about [asciinema](https://asciinema.org/docs/usage)

## Record screen using ffmpeg in Windows  
- Download Setup Screen Capturer Recorder v0.12.10.noasync.exe from https://sourceforge.net/projects/screencapturer/files/
- Install the "Screen Capturer Recorder" and add ffmpeg to Path
- Check if the screen capture recorder and audio recorder installed successfully
```
ffmpeg -list_devices true -f dshow -i dummy
```
- To capture with ffmpeg, try below command
```
ffmpeg -f dshow -i video="screen-capture-recorder" -f dshow -i audio="virtual-audio-capturer" -pix_fmt yuv420p -vcodec libx264 -acodec libvo_aacenc -s 1280x720 -r 25 -q 10 -ar 44100 -ac 2 -tune zerolatency -preset ultrafast -f mpegts - | ffmpeg -f mpegts -i - -c copy -bsf:a aac_adtstoasc -f flv temp.flv  
```
