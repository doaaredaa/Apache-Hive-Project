#!/bin/bash
sudo service ssh start

if hostname | grep -q 'Master'; then
    hdfs --daemon start journalnode
    /usr/local/zookeeper/bin/zkServer.sh start
    Node_Number=$(hostname | tail -c 2)
    echo $Node_Number > /usr/local/zookeeper/data/myid
    if [ "$Node_Number" -eq "1" ]; then
        hdfs namenode -format 
        hdfs zkfc -formatZK
        hdfs --daemon start namenode 
    else
        until nc -zw 2 master1 8020; do
            echo "Waiting for master1 to be available..."
            sleep 2
        done
        hdfs namenode -bootstrapStandby 
        hdfs --daemon start namenode 
    fi
    
    yarn --daemon start resourcemanager 
    hdfs --daemon start zkfc

elif hostname | grep -q 'Worker'; then
    hdfs --daemon start datanode 
    yarn --daemon start nodemanager

elif hostname | grep -q 'Metastore'; then
    if [ ! -f /usr/local/hive/metastore_db/metastore_db ]; then
        echo "Creating Metastore database..."
        schematool -initSchema -dbType postgres
        touch /usr/local/hive/metastore_db/metastore_db
    fi

    hive --service metastore 

elif hostname | grep -q 'HiveServer2'; then
    hive --service hiveserver2 &
    sleep 10

    hdfs dfs -mkdir -p /app/tez
    hdfs dfs -put /usr/local/tez/share/tez.tar.gz  /app/tez
    hdfs dfs chmod -R 777 /app/tez


fi

hdfs haadmin -getAllServiceState
yarn rmadmin -getServiceState

sleep infinity