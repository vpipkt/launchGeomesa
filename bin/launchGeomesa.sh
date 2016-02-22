#!/bin/bash

# pick up variables from conf file  
source ./conf/launchGeomesa.conf

mkdir pkg 

if [ ! -z "${gm_dist_lfs}" ]; then
  cp ${gm_dist_lfs} pkg
elif [ ! -z "${gm_dist_s3}" ]; then
  aws s3 cp ${gm_dist_s3} pkg
fi

tar xvfz pkg/${gm_tarball} -C pkg
tar xvfz pkg/geomesa-${gm_version}/dist/tools/geomesa-tools-${gm_version}-bin.tar.gz -C ..
chown hdfs pkg/geomesa-${gm_version}/dist/accumulo/geomesa-accumulo-distributed-runtime-${gm_version}.jar
export GEOMESA_HOME="$(pwd)/../geomesa-tools-${gm_version}"

# this should print geomesa build date etc
$GEOMESA_HOME/bin/geomesa version

read -p "did this print geomesa version?"

# set up accumulo namespace
echo Deploying geomesa accumulo runtime on hdfs for namespace ${gm_namespace}
chown hdfs pkg/geomesa-${gm_version}/dist/accumulo/geomesa-accumulo-distributed-runtime-${gm_version}.jar
sudo -u hdfs -i hadoop fs -mkdir -p /accumulo/classpath/${gm_namespace}
sudo -u hdfs -i hadoop fs -put pkg/geomesa-${gm_version}/dist/accumulo/geomesa-accumulo-distributed-runtime-${gm_version}.jar ${namenode}/accumulo/classpath/${gm_namespace}/

read -p "Did geomesa dist get put to hdfs?"


echo create accumulo namespace
# build out accumulo-shell script 
cat <<EOF >>bin/accumulo
deletenamespace ${gm_namespace} f
createnamespace ${gm_namespace}
grant NameSpace.CREATE_TABLE -ns ${gm_namespace} -u ${accumulo_user}
config -s general.vfs.context.classpath.${gm_namespace}=${namenode}/accumulo/classpath/${gm_namespace}/[^.].*.jar
config -ns ${gm_namespace} -s table.classpath.context=${gm_namespace}
bye
EOF

accumulo shell -u ${accumulo_user} -p ${accumulo_password} -f ./bin/accumulo

read -p "Accumulo classpath set up ok?"

echo Test local ingest
$GEOMESA_HOME/bin/geomesa ingest -u ${accumulo_user} -p ${accumulo_password} -c ${gm_namespace}.${gm_catalog} -s example-csv -C example-csv $GEOMESA_HOME/examples/ingest/csv/example.csv

# this will test distributed ingest
./bin/hdfs_ingest.sh $GEOMESA_HOME

