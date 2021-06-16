#!/bin/bash
# Test on CentOS Linux release 7.9.2009 (Core)
yum remove nodejs
curl -fsSL https://rpm.nodesource.com/setup_16.x | bash -
sudo yum install -y nodejs
yum install dnf
sudo dnf install https://dl.k6.io/rpm/repo.rpm
printf "y\ny\n" | sudo yum install --nogpgcheck k6
