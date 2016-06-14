# GeoMesa Elastic Map Reduce Bootstrap Scripts
__TODO__: fix path to bootstrap script!!

## Using the GeoMesa bootstrap

You can use the scripts staged to s3 here:

```
s3://somebucketc/././/bootstrap-geomesa.sh
```

You can also put these scripts to any S3 bucket which your EMR instances will be able to access using thier IAM role. Be sure to update the path to `bootstrap-geomesa-lib.sh` in step #1 of `bootstrap-geomesa.sh`.

The bootstrap requires EMR installation of Hadoop and ZooKeeper applications.

### Example EMR command

The command below is intended to launch the cluster into default VPC of the region specified.

``` bash
NUM_WORKERS=2
CLUSTER_NAME=geomesa-emr
AWS_REGION=us-east-1
AWS_PROFILE=my_profile
KEYPAIR_NAME=my_keypair # a keypair in the region (for which you have the private key)
SUBNET_ID=subnet-abcd1234 # a subnet on the default VPC in the region
MASTER_SECURITY_GROUP=sg-1234abcd
SLAVE_SECURITY_GROUP=sg-abcd1234

aws emr create-cluster --applications Name=Hadoop Name=ZooKeeper-Sandbox \
    --bootstrap-actions Path=s3://geoint-data/emr-get-started/bootstrap/geomesa/bootstrap-geomesa.sh,Name=geomesa \
    --ec2-attributes KeyName=$KEYPAIR_NAME,SubnetId=${SUBNET_ID},InstanceProfile=EMR_EC2_DefaultRole,EmrManagedSlaveSecurityGroup=${SLAVE_SECURITY_GROUP},EmrManagedMasterSecurityGroup=${MASTER_SECURITY_GROUP} \
    --service-role EMR_DefaultRole \
    --release-label emr-4.7.1 --name $CLUSTER_NAME \
    --instance-groups InstanceCount=$NUM_WORKERS,InstanceGroupType=CORE,InstanceType=m3.xlarge InstanceCount=1,InstanceGroupType=MASTER,InstanceType=m3.xlarge \
    --region $AWS_REGION \
    --profile $AWS_PROFILE
```

## Good to know

### Stage tarball on S3

Inside AWS resources, downloading the GeoMesa binaries is fastest over S3.  You can stage the latest release in a bucket which your EMR instance can access using their IAM role. Then set `GEOMESA_DIST_S3` in `bootstrap-geomesa.sh`.

### Environment

The Accumulo instance name defaults to `accumulo`. It is set via `ACCUMULO_INSTANCE` in `bootstrap-geomesa-lib.sh`. 
The Accumulo `root` user password is set via `USERPW` in `bootstrap-geomesa.sh`.  By default it is `secret`.

The ZooKeeper address is the hostname of the master instance, with the default port of 2181.

An Accumulo namespace is set up for the version, following the pattern `geomesa_122`, that is `geomesa_` appended with the version number removing periods. Tables names prefixed with `geomesa_122.` automatically have the GeoMesa distributed runtime jar on the classpath.  

On the master instance, user `hadoop` is set up with GeoMesa tools.  `$GEOMESA_HOME` set to `~hadoop/geomesa-tools-${GEOMESA_VERSION}`. The `$HADOOP_HOME` and `$ACCUMULO_HOME` are also set up to allow suppressing the `-i` and `-z` commands when connecting to the accumulo instance through `geomesa` command line interface.

### Logging of bootstrap steps

Bootstrapping steps are logged to `/tmp/bootstrap-geomesa.log`.

### Resizing

Each node added to the CORE instance group will be bootstrapped as an Accumulo tablet server. It will pick up necessary distributed runtime jar via the Accumulo namespace.

