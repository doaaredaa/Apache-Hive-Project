#
export HADOOP_OS_TYPE=${HADOOP_OS_TYPE:-$(uname -s)}

export HADOOP_OPTS="-Djava.net.preferIPv4Stack=true"
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export HADOOP_HOME_WARN_SUPPRESS="TRUE"
export HADOOP_ROOT_LOGGER="WARN,DRFA"
export HADOOP_HOME=/usr/local/hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
