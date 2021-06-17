#!/bin/sh

get_package()
{
  cmd="sudo wget https://mirrors.estointernet.in/apache/zookeeper/zookeeper-3.7.0/apache-zookeeper-3.7.0-bin.tar.gz"
  $cmd
}


add_user()
{
  sudo useradd zookeeper -m
  sudo usermod --shell /bin/bash zookeeper
  sudo passwd zookeeper
  #2wer43@WER$#
  sudo usermod -aG sudo zookeeper
  sudo mkdir -p /data/zookeeper
  sudo chown -R zookeeper:zookeeper /data/zookeeper
  #su - zookeeper
  #cd /opt
}

config_zk()
{
sudo tee /opt/zookeeper/conf/zoo.cfg <<EOL
tickTime=2000
dataDir=/data/zookeeper
clientPort=2181
initLimit=5
syncLimit=2
EOL

/opt/zookeeper/bin/zkServer.sh start
}

enable_service()
{
sudo tee /etc/systemd/system/zookeeper.service <<EOL
[Unit]
Description=Zookeeper Daemon
Documentation=http://zookeeper.apache.org
Requires=network.target
After=network.target

[Service]
Type=forking
WorkingDirectory=/opt/zookeeper
User=zookeeper
Group=zookeeper
ExecStart=/opt/zookeeper/bin/zkServer.sh start /opt/zookeeper/conf/zoo.cfg
ExecStop=/opt/zookeeper/bin/zkServer.sh stop /opt/zookeeper/conf/zoo.cfg
ExecReload=/opt/zookeeper/bin/zkServer.sh restart /opt/zookeeper/conf/zoo.cfg
TimeoutSec=30
Restart=on-failure

[Install]
WantedBy=default.target
EOL

sudo systemctl daemon-reload
sudo systemctl enable zookeeper
sudo systemctl restart zookeeper
}
