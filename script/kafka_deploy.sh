#!/bin/bash

wget https://apache.claz.org/kafka/2.8.0/kafka_2.12-2.8.0.tgz
tar xzvf kafka_2.12-2.8.0.tgz -C /opt/
#mv /opt/kafka_2.12-2.8.0 /opt/kafka

#sudo tee /opt/kafka/config/server2.properties <<EOL
#zookeeper.connect=localhost:2181
#broker.id=0
#log.dirs=/data/kafka-logs
#EOL

/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties
#/opt/bin/kafka-server-stop.sh /opt/kafka/config/server.properties
