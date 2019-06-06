#Tips for install & configure vim 8.1 on CentOS 7.6

# cat /etc/centos-release
CentOS Linux release 7.6.1810 (Core)

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

### Download Vim source
```
git clone https://github.com/vim/vim.git
cd vim
```

### Configure
```
./configure --with-features=huge \
--enable-multibyte    \
--enable-rubyinterp   \
--enable-pythoninterp \
--enable-perlinterp   \
--enable-luainterp
```

### Build
```
make
make install
```


#### Check Vim version
```
vim --version | less
```
check if: +lua +multi_byte +perl +python +ruby 
