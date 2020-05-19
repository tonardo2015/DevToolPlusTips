# Tips for install & configure vim 8.1 on CentOS 7.6

```
#cat /etc/centos-release
CentOS Linux release 7.6.1810 (Core)
```

### Install all the prerequisite libraries

```
yum install gcc make ncurses ncurses-devel
yum install ctags git tcl-devel \
ruby    ruby-devel     \
lua     lua-devel      \
luajit  luajit-devel   \
python  python-devel   \
python3 python3-devel  \
perl    perl-devel     \
perl-ExtUtils-ParseXS  \
perl-ExtUtils-XSpp     \
perl-ExtUtils-CBuilder \
perl-ExtUtils-Embed
```

### Remove the existing Vim if you have already installed it
```
yum list installed | grep -i vim
yum remove vim-enhanced vim-common vim-filesystem
```

## Download Vim source
```
git clone https://github.com/vim/vim.git
cd vim
```

### Configure
```
./configure --with-features=huge \
--enable-multibyte \
--enable-python3interp \
--enable-rubyinterp \
--enable-perlinterp \
--enable-luainterp \
--enable-cscope \
--enable-largefile \
--enable-fail-if-missing \
--prefix=/usr/local/

```

Note: VIM does not support python and python3 at the same time.
UltiSnips.vim has some problem with python, error like below would
occur with python:
E837: This Vim cannot execute :py3 after using :python

It is recommended to compile vim with python3 support.

You can use below method to check your vim's python enablement:
Enter command mode, type `:echo has('python3')` or `:echo has('python')`.
If the output is '1', it means supported, else the output is '0'.

### Build
```
make
make install
```


### Check Vim version
```
vim --version | less
```
check if: +lua +multi_byte +perl +python +ruby 

## Change color scheme of vim 
1. Enter command mode and input ":terminal"
2. Check available color scheme in the system by command 
```
ls -l /usr/share/vim/vim*/colors/
```
3. Edit "~/.vimrc" and add below lines
```
syntax on
colorscheme torte
```
Note: The "torte" here is the color scheme you choose for update

```
ln -s /usr/local/bin/vim /usr/bin/vim 
```
## To customize VIM into one IDE  
Install the dependency, including nodejs, ag

1. First, update the local repository to ensure you install the latest versions of Node.js and npm. Type in the following command:
```c
sudo yum update
```
2. Next, add the NodeSource repository to the system with:
```c
curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -
```
3. The output will prompt you to use the following command if you want to install Node.js and npm:
```c
sudo yum install -y nodejs
```
4. Finally, verify the installed software with the commands:
```c
node -version
npm -version
```
Reference: https://phoenixnap.com/kb/install-node-js-npm-centos

## Installing ag on CentOS  
#### Prerequistes  
- libpcre
- liblzma

Download, build and install
```c
sudo yum install -y pcre-devel
sudo yum install xz-devel
cd /usr/local/src
sudo git clone https://github.com/ggreer/the_silver_searcher.git
cd the_silver_searcher
sudo ./build.sh
sudo make install
which ag

# Another way to install ag
yum install -y the_silver_searcher
```
Reference:  
https://gist.github.com/rkaneko/988c3964a3177eb69b75  

## Clone and install vim config  
```c
git clone https://github.com/sebdah/vim-ide.git
cd vim-ide
sudo ./install.sh
```
Reference:  
https://github.com/sebdah/vim-ide
https://vimawesome.com/
https://tpaschalis.github.io/vim-go-setup/
