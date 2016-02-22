#!/bin/bash

# pick up variables from conf file  
source ./conf/launchGeomesa.conf
echo lfs: ${gm_dist_lfs}

mkdir pkg 

if [ ! -z "${gm_dist_lfs}" ]; then
  cp ${gm_dist_lfs} pkg
elif [ ! -z "${gm_dist_s3}" ]; then
  aws s3 cp ${gm_dist_s3} pkg
fi

tar xvfz pkg/geomesa-${gm_version}-bin.tar.gz -C pkg
tar xvfz pkg/geomesa-${gm_version}/dist/tools/geomesa-tools-${gm_version}-bin.tar.gz -C ..
export GEOMESA_HOME="$(pwd)/../geomesa-tools-${gm_version}"
echo GEOMESA_HOME set to: $GEOMESA_HOME
# this should print available converter configs
$GEOMESA_HOME/bin/geomesa env

# set up accumulo namespace
echo Deploying geomesa accumulo runtime on hdfs for namespace ${gm_namespace}
HADOOP_USER=hdfs hadoop fs -mkdir -p /accumulo/classpath/${gm_namespace}
HADOOP_USER=hdfs hadoop fs -put pkg/geomesa-${gm_version}/dist/accumulo/geomesa-accumulo-distributed-runtime-${gm_version}.jar ${namenode}/accumulo/classpath/${gm_namespace}/

echo create accumulo namespace
# build out accumulo-shell script 
cat <<EOF >>bin/accumulo
createnamespace ${gm_namespace}
grant NameSpace.CREATE_TABLE -ns ${gm_namespace} -u ${accumulo_user}
config -s general.vfs.context.classpath.${gm_namespace}=${namenode}/accumulo/classpath/${gm_namespace}/[^.].*.jar
config -ns ${gm_namespace} -s table.classpath.context=${gm_namespace}
bye
EOF

accumulo shell -u ${accumulo_user} -p ${accumulo_password} -f ./bin/accumulo

echo Test local ingest
$GEOMESA_HOME/bin/geomesa ingest -u ${accumulo_user} -p ${accumulo_password} -c ${gm_namespace}.${gm_catalog} -s example-csv -C example-csv $GEOMESA_HOME/examples/ingest/csv/example.csv

# this will test distributed ingest
./bin/hdfs_ingest.sh $GEOMESA_HOME

