FROM ubuntu:22.04

# Install base dependencies
RUN apt-get update && \
    apt-get install -y \
    openjdk-8-jdk \
    openssh-server \
    ssh \
    wget \
    vim \
    sudo \
    netcat \
    postgresql-client \
    net-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ENVIRONMENT VARIABLE = bashrc
ENV HADOOP_HOME=/usr/local/hadoop
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH
#
ENV HIVE_HOME=/usr/local/hive
ENV TEZ_HOME=/usr/local/tez
ENV PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin:$HIVE_HOME/bin:$TEZ_HOME/bin
ENV HADOOP_CLASSPATH=/usr/local/hadoop/etc/hadoop:/usr/local/hive/lib/:/usr/local/tez/lib/:/usr/local/tez/*
#
ENV HADOOP_INSTALL=$HADOOP_HOME  
ENV HADOOP_MAPRED_HOME=$HADOOP_HOME  
ENV HADOOP_COMMON_HOME=$HADOOP_HOME  
ENV HADOOP_HDFS_HOME=$HADOOP_HOME  
ENV HADOOP_YARN_HOME=$HADOOP_HOME  
ENV HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native  
ENV HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"
ENV ZOOKEEPER_HOME=/usr/local/zookeeper/bin/zkServer.sh

RUN addgroup hadoop-group
RUN adduser --disabled-password --gecos "" --ingroup hadoop-group hadoop
RUN echo "hadoop ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install ZooKeeper
RUN wget https://dlcdn.apache.org/zookeeper/zookeeper-3.8.4/apache-zookeeper-3.8.4-bin.tar.gz 
RUN tar -xvzf apache-zookeeper-3.8.4-bin.tar.gz -C /usr/local
RUN mv /usr/local/apache-zookeeper-3.8.4-bin /usr/local/zookeeper
RUN mkdir -p /usr/local/zookeeper/data
RUN chown -R hadoop:hadoop-group /usr/local/zookeeper
RUN chmod -R 777 /usr/local/zookeeper

# Install Hadoop
RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
RUN tar -xvzf hadoop-3.3.6.tar.gz -C /usr/local
RUN sudo mv /usr/local/hadoop-3.3.6 /usr/local/hadoop
RUN sudo chown -R hadoop:hadoop-group /usr/local/hadoop
RUN sudo chmod -R 777 /usr/local/hadoop

# Install Hive
RUN wget -q https://archive.apache.org/dist/hive/hive-4.0.1/apache-hive-4.0.1-bin.tar.gz 
RUN tar -xzf apache-hive-4.0.1-bin.tar.gz -C /usr/local 
RUN mv /usr/local/apache-hive-4.0.1-bin /usr/local/hive 
RUN rm apache-hive-4.0.1-bin.tar.gz 
RUN wget -q https://jdbc.postgresql.org/download/postgresql-42.5.4.jar -P /usr/local/hive/lib/
RUN chown -R hadoop:hadoop-group /usr/local/hive

# Install Tez
RUN wget -q https://dlcdn.apache.org/tez/0.10.4/apache-tez-0.10.4-bin.tar.gz
RUN tar -xzf apache-tez-0.10.4-bin.tar.gz -C /usr/local 
RUN mv /usr/local/apache-tez-0.10.4-bin /usr/local/tez
RUN rm apache-tez-0.10.4-bin.tar.gz 
RUN chown -R hadoop:hadoop-group /usr/local/tez


# switch user to hadoop
USER hadoop 
WORKDIR /home/hadoop

# Configure SSH
RUN ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
RUN chmod 600 ~/.ssh/authorized_keys

COPY hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh
COPY hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
COPY core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
COPY yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
COPY mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
COPY workers $HADOOP_HOME/etc/hadoop/workers
COPY zoo.cfg /usr/local/zookeeper/conf/zoo.cfg
COPY entrypoint.sh /home/hadoop/entrypoint.sh
#
COPY tez-site.xml $TEZ_HOME/conf/
COPY hive-site.xml $HIVE_HOME/conf/
#

RUN sudo mkdir -p /hadoop/dfs/name
RUN sudo chown -R hadoop:hadoop-group /hadoop/dfs/name
RUN sudo chmod -R 777 /hadoop/dfs/name

RUN sudo mkdir -p /hadoop/dfs/data
RUN sudo chown -R hadoop:hadoop-group /hadoop/dfs/data
RUN sudo chmod -R 777 /hadoop/dfs/data

RUN sudo chmod +x ~/entrypoint.sh
ENTRYPOINT [ "./entrypoint.sh" ]