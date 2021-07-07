#!/usr/bin/env bash

inst_python_env()
{
  yum remove -y nodejs
  curl -fsSL https://rpm.nodesource.com/setup_16.x | bash -
  sudo yum install -y nodejs
  yum install -y dnf
  sudo dnf install https://dl.k6.io/rpm/repo.rpm
  printf "y\ny\n" | sudo yum install --nogpgcheck k6
  #sudo yum install -y --nogpgcheck k6

  sudo yum install -y epel-release
  wget https://www.python.org/ftp/python/3.9.5/Python-3.9.5.tgz
  tar zxf Python-3.9.5.tgz
  cd Python-3.9.5
  yum update -y
  yum groupinstall -y 'Development Tools'
  yum install -y gcc openssl-devel bzip2-devel libffi-devel
  #./configure prefix=/usr/local/python3 --enable-optimizations
  ./configure prefix=/usr/local/python3
  make && make install
  cd ..

  #which python
  mv /usr/bin/python /usr/bin/python2.bak

  if [ $(grep python2 /usr/bin/yum | wc -l) -eq 0 ]; then
    cp /usr/bin/yum /usr/bin/yum.bk
    sudo sed -i '1s/\/usr\/bin\/python/\/usr\/bin\/python2/' /usr/bin/yum
  else
    echo "yum already updated, no action required"
  fi
  if  [ $(grep python2 /usr/libexec/urlgrabber-ext-down | wc -l) -eq 0 ]; then
    cp /usr/libexec/urlgrabber-ext-down /usr/libexec/urlgrabber-ext-down.bk
    sudo sed -i '1s/\/usr\/bin\/python/\/usr\/bin\/python2/' /usr/libexec/urlgrabber-ext-down
  else
    echo "urlgrabber-ext-down already updated, no action required"
  fi

  ln -s /usr/local/python3/bin/python3.9 /usr/bin/python
  ln -s /usr/local/python3/bin/pip3.9 /usr/bin/pip
  ln -s /usr/local/python3/bin/pip3.9 /usr/bin/pip3

  yum install -y postgresql-devel

  python -m pip install --upgrade pip
  pip install -r ./requirements
}

upgrade_vim()
{

  yum install -y gcc make ncurses ncurses-devel
  yum install -y ctags git tcl-devel ruby ruby-devel lua lua-devel luajit luajit-devel python  python-devel python3 python3-devel perl perl-devel perl-ExtUtils-ParseXS perl-ExtUtils-XSpp perl-ExtUtils-CBuilder perl-ExtUtils-Embed

  yum list installed | grep -i vim
  yum remove -y vim-enhanced vim-common vim-filesystem

  git config --global url."https://hub.fastgit.org".insteadOf https://github.com
  git clone https://github.com/vim/vim.git

  cd vim
  ./configure --with-features=huge --enable-multibyte --enable-python3interp --enable-rubyinterp --enable-perlinterp --enable-luainterp --enable-cscope --enable-largefile --enable-fail-if-missing --prefix=/usr/local/

  make && make install
  cd ..
  ln -s /usr/local/bin/vim /usr/bin/vim

  yum install -y the_silver_searcher

  git clone https://github.com/sebdah/vim-ide.git
  cd vim-ide
  sudo ./install.sh
  cd ..
}

inst_golang_env()
{
  echo "Install golang development environment"

  # yum install go 1.15 only
  #yum install -y golang

  #Reference: https://gomirrors.org/ to get download go package URL
  wget https://gomirrors.org/dl/go/go1.16.5.linux-amd64.tar.gz
  tar xzvf go1.16.5.linux-amd64.tar.gz -C /usr/local/

  #export GOPROXY=https://mirrors.aliyun.com/goproxy/
  #echo 'export GOROOT=/usr/lib/golang' >> ~/.bashrc  # For yum installed go

  export GOPROXY=https://goproxy.io,direct

  echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
  echo 'export GOPATH=$HOME/goproj' >> ~/.bashrc
  echo 'export GOBIN=$GOPATH/bin' >> ~/.bashrc
  echo 'export PATH=$PATH:$GOROOT/bin' >> ~/.bashrc
  echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc

  source ~/.bashrc
  go env
  git clone https://hub.fastgit.org/fatih/vim-go.git ~/.vim/pack/plugins/start/vim-go
}

inst_python_env
upgrade_vim
inst_golang_env
