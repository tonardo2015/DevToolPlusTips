#!/bin/bash

tar xzvf node_exporter-1.1.2.linux-amd64.tar.gz -C /usr/local/
ln -s /usr/local/node_exporter-1.1.2.linux-amd64/node_exporter /usr/local/bin/node_exporter

sudo tee /etc/systemd/system/node_exporter.service <<EOL
[Unit]
Description=Node Exporter
After=network.target

[Service]
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOL

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter
