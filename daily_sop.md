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
mount 10.10.0.10:/backups /var/backups
umount /var/backups

# showmount <NFS-Server-IP> -e, e.g:
# showmount 10.228.44.97 -e
Export list for 10.228.44.97:
/nfsOverUDPonPool1 (everyone)
/nfsonPool1        (everyone)

# rpcinfo -p <NFS-Server-IP> | egrep "service|nfs", e.g:
# rpcinfo -p 10.228.44.97 | egrep "service|nfs"
   program vers proto   port  service
    100003    4   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100003    3   udp   2049  nfs

#mount with UDP (only support in NFSv3)
mount -t nfs -o rw,vers=3,proto=udp 10.228.44.97:/nfsonPool1 /tmp/mount_nfs
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

# Capture on Protocol
tcpdump -i eth0 udp
tcpdump -i eth0 proto 17

# Capture based on IP
tcpdump -i eth0 host 10.10.1.1

# Save to a capture file
tcpdump -i eth0 -s0 -w test.pcap

# Read PCAP file
tcpdump -r test.pcap

# Display ASCII text
tcpdump -A -s0 port 80

# Capture on Protocol
tcpdump -i eth0 udp
tcpdump -i eth0 proto 17

```
#### Line Buffered Mode
> Without the option to force line (`-l`) buffered (or packet buffered `-C`) mode you will not always get the expected response when piping the tcpdump output to another command such as grep. By using this option the output is sent immediately to the piped command giving an immediate response when troubleshooting.
```
sudo tcpdump -i eth0 -s0 -l port 80 | grep 'Server:'
```

> 
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

## How to update a python package using pip
```
# Check package version
$ pip3 freeze | grep [package_name]
$ sudo pip install [package_name] --upgrade
or
$ sudo pip install [package_name] -U
```
e.g.
```
$ pip3 freeze | grep storops
storops==1.0.0
$ sudo pip3 install storops -U
```
If you want to batch update all packages, try below cmd
```
for i in $(pip list -o | awk 'NR > 2 {print $1}'); do sudo pip install -U $i; done
```
## Variable compare with shell
> - For string or regex test, try to use `==`, `=~` or `!=`  
> - For integer, try to use `-eq`, `-gt`, `-lt`  
```
if [ "${PACKAGENAME}" = 'kakadu-v6_4-00902C' ]; then
    echo "successfully entered if block!!"
fi
```
> Because if ${PACKAGENAME} contains a whitespace or wildcard character, then it will be split into multiple arguments, which causes to make [ see more arguments than desired.

## Find files named 'file.txt' and execute a sed command
```
find . -name 'file.txt' -exec sed command {} +
find . -name 'file.txt' -execdir sed command {} +
find . -name 'file.txt' -type f | xargs sed command
find . -name 'file.txt' -exec send command {} \;  
find . -name 'file.txt' -print0 | xargs -0 sed 'some sed stuff' -i
```
> Note:  
`find -exec` spawns one process per file, while xargs uses one sed for all files, which is much faster if you have a lot of files

## Install ShellCheck in SLES 15/CentOS 7
- What is [ShellCheck](https://github.com/koalaman/shellcheck)?  
```
** SLES 15 **
zypper addrepo https://download.opensuse.org/repositories/openSUSE:Backports:SLE-15-SP2/standard/openSUSE:Backports:SLE-15-SP2.repo
zypper refresh
zypper install ShellCheck

** CentOS **
sudo yum -y install epel-release
sudo yum install ShellCheck
```
> SLES/OpenSUSE package download site https://software.opensuse.org/distributions

- VIM ShellCheck integration using [Syntastic](https://github.com/vim-syntastic/syntastic)
> If you are using NeoBundle, add below line in your `~/.vimrc`
```
NeoBundle 'scrooloose/syntastic'
```
Reference:  
> [shellcheck-shell-script-code-analyzer-for-linux](https://www.tecmint.com/shellcheck-shell-script-code-analyzer-for-linux/)  
> [ShellCheck Online](https://www.shellcheck.net/)

## How to kill one background process
```
ps -eaf | grep [w]get 
kill <pid>

pgrep wget
kill <pid>

pkill wget

killall wget

jobs
kill %<jobId>

jobs
fg <jobId>
^c
```

## VIM package manager collection
- [Vim Plug](https://github.com/junegunn/vim-plug)  
    - Add `Plug 'bling/vim-airline'` in `~/.vimrc` then execute `:PlugInstall`
- [Vundle](https://github.com/VundleVim/Vundle.vim)  
    - Add `Plugin 'bling/vim-airline'` in `~/.vimrc` then execute `:PluginInstall`
    - [Vundle Tutorial](https://linuxhint.com/vim-vundle-tutorial/)
- [Vim Pathogen](https://github.com/tpope/vim-pathogen)  
    - `cd ~/.vim/bundle` then `git clone https://github.com/bling/vim-airline`
- [vim-addon-manager(VAM)](https://github.com/MarcWeber/vim-addon-manager)  
- [NeoBundle](https://github.com/Shougo/neobundle.vim)  
    - Add `NeoBundle 'vim-airline/vim-airline'` in `~/.vimrc` then execute `:NeoBundleInstall`


## How to solve the problem that you can't paste into vim
> There are 2 options that you can do  
- Modify your .vimrc and add `set mouse=v`
- Hold "Shift" and then Insert(`Ins` key)

## NeoBundle installation
```
$ curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh > install.sh
$ sh ./install.sh

#Then modify your .vimrc and add below content

"NeoBundle Scripts-----------------------------
if &compatible
  set nocompatible               " Be iMproved
endif

" Required:
set runtimepath+=/root/.vim/bundle/neobundle.vim/

" Required:
call neobundle#begin(expand('/root/.vim/bundle'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" Add or remove your Bundles here:
NeoBundle 'Shougo/neosnippet.vim'
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'ctrlpvim/ctrlp.vim'
NeoBundle 'flazz/vim-colorschemes'

" You can specify revision/branch/tag.
NeoBundle 'Shougo/vimshell', { 'rev' : '3787e5' }

" Required:
call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck
"End NeoBundle Scripts-------------------------
```
> `:NeoBundleList` - list configured bundles  
> `:NeoBundleInstall(!)` - install (update) bundles

> To install airline, add below line in your `~/.vimrc` 
```
NeoBundle 'vim-airline/vim-airline'
NeoBundle 'flazz/vim-colorschemes' 
```
> And then issue `:NeoBundleInstall` to do the installation  
> `NeoBundle 'flazz/vim-colorschemes'` is for [VIM colorscheme](https://www.varstack.com/2015/07/08/Vim-Colorscheme/)

## How To Debug a Bash Shell Script Under Linux or UNIX
> Run a shell script with -x option
```
$ bash -x script-name
```  
> Use of set builtin command
Bash shell offers debugging options which can be turn on or off using the set command:
- `set -x` : Display commands and their arguments as they are executed.  
- `set -v` : Display shell input lines as they are read.  

#### Shell Intelligent Debug
> Add a special variable named `_DEBUG` and set it to 'on' when debugging a script
```
_DEBUG="on"
```
> Put following function at the beginning of script
```
function DEBUG()
{
 [ "$_DEBUG" == "on" ] &&  $@
}
```
> Use the DEBUG function as following:
```
DEBUG echo "File is $filename"
```
> OR 
```
DEBUG set -x
Cmd1
Cmd2
DEBUG set +x
```
> When debug is done, set `_DEBUG` to 'off'. No need to delete debug lines
```
_DEBUG="off"
```

## How to create custom header template for shell script in VIM
> - Create a template file, e.g. sh_header.temp in `~/.vim/`
```
#!/bin/bash

###################################################################
#Script Name	:
#Description	:
#Args           	:
#Author       	: Dummy Dev
#Email         	: Dev@gmail.com
###################################################################
```
> - Update your `~/.vimrc` with below line
```
au bufnewfile *.sh 0r ~/.vim/sh_header.temp
```
## Cmder configuration
- What is [Cmder](https://cmder.net/)  
- How to install?
    - Download from [Cmder site](https://cmder.net/) 
    - Unzip
    - Put the executable to you preferred installation folder, e.g. `C:\Program Files\cmder`
    - Run `Cmder`
- Hot Keys
```
Ctrl + ` : Global Summon from taskbar
Win + Alt + p : Preferences (Or right click on title bar)
Ctrl + t : New tab dialog (maybe you want to open cmd as admin?)
Ctrl + w : Close tab
Shift + Alt + number : Fast new tab:
    1. CMD
    2. PowerShell
Alt + Enter : Fullscreen
```
- Advanced configuration  
    - change command prompt 
    > Modify `vendor\clink.lua` in cmder installation folder and replace below lines with your changes  
    ```
    local cmder_prompt = "\x1b[1;32;40m{cwd} {git}{hg}{svn} \n\x1b[2;37;40m{lamb} \x1b[0m"
    local lambda = "λ"
    ```
    - How to solve the word overlap issue  
    `Win + ALT + P` to launch configuration window and check off the 'Monospace' in 'Fonts'

    - `ls` Chinese character support  
    `WIN + ALT + P` to launch configuraiton window, `Startup` -> `Environment`, add one line `set LANG=zh_CN.UTF-8`  
- [Cmder reference](https://www.jianshu.com/p/26acbe2c72a7)

## How to grant user `sudo` permission in CentOS
- Enable `wheel` group
> Open the configuration by below command
```
visudo
```
check if below entry in the file
```
## Allows people in group wheel to run all commands
%wheel        ALL=(ALL)       ALL
```
- Add him/her to `wheel` group
```
usermod -aG wheel <Username>
```

## How to view .wrf file
> Download WebEx Player from https://www.webex.com/video-recording.html

## How to convert WRF file to mp4
> Refer to https://case.edu/utech/sites/case.edu.utech/files/2019-05/Recording%20Instructions%20for%20webex%20mp4.pdf

