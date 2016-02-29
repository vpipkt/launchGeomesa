#!/bin/bash

GEOMESA_HOME=$1

source ./conf/launchGeomesa.conf

# Write out geomesa conf file for sft and converter
cat <<EOF >>/tmp/hdfsExample.sft
geomesa.sfts.hdfsExample = {          
		attributes = [
			{ name = "pointid", type = Integer }
			{ name = "geom", type = Point, srid = 4326 }
			{ name = "dtg", type = Date }
		]
  }
EOF
cat <<EOF >>/tmp/hdfsExample.convert
geomesa.converters.hdfsExample = {
		type = "delimited-text"
		format = "TSV"
		id-field = "uuid()"
		fields = [
			{ name = "pointid", transform = "\$1::integer" }
			{ name = "geom", transform = "point(\$3::double, \$4::double)" }
			{ name = "dtg", transform = "date('YYYY-MM-dd HH:mm:ss', \$2)" }
		]
}
EOF

# Write out 10 small files to hdfs
mkdir /tmp/hdfs_sample

cat <<EOF >>/tmp/hdfs_sample/data1.tsv
0	2014-03-24 04:50:25	-169.709189040586	-7.09094132995233
1	2015-05-15 13:30:51	80.1075420062989	82.5987977371551
2	2016-01-01 23:27:18	-104.515173733234	44.0032548713498
3	2015-01-23 11:05:19	6.8443064019084	54.2590800207108
4	2014-11-05 12:54:14	101.811242094263	43.4106063330546
5	2015-07-05 02:04:12	-105.534876342863	61.7052581929602
6	2015-02-05 13:09:22	-164.83762842603	39.6631198050454
7	2015-05-10 04:51:15	113.488474152982	-17.6239181053825
8	2014-05-09 15:29:34	171.066839592531	-25.162609834224
9	2015-08-17 22:51:59	-7.97786945477128	-49.554579379037
EOF

cat <<EOF >>/tmp/hdfs_sample/data2.tsv
10	2015-09-06 07:21:42	159.257031474262	-14.8856369196437
11	2014-06-19 13:51:42	14.614673210308	-58.393094711937
12	2015-03-22 20:47:54	139.438164420426	67.3600661498494
13	2014-02-01 22:30:39	82.852205587551	-3.85486073093489
14	2014-05-01 23:33:00	125.037900544703	31.9347481522709
15	2015-05-26 17:50:57	-47.6283961907029	-59.2651309771463
16	2014-07-19 04:13:32	-129.687093961984	-21.0514804837294
17	2015-02-20 06:18:34	-84.729879386723	-17.1544313291088
18	2015-04-23 03:35:41	110.257674688473	-11.6332837333903
19	2014-04-13 22:09:47	-33.0797226727009	-83.6028232448734
EOF

cat <<EOF >>/tmp/hdfs_sample/data3.tsv
20	2014-01-24 13:38:56	103.557175928727	67.2971420013346
21	2015-10-22 20:51:40	158.681027004495	-17.4581306264736
22	2014-04-26 04:09:53	131.48791719228	48.2244807807729
23	2014-11-28 07:27:55	85.261567812413	11.5690555423498
24	2014-03-03 12:24:16	-13.4563244506717	-30.7916332455352
25	2015-04-09 20:17:46	89.937834944576	71.3657838129438
26	2015-10-11 20:28:59	56.7330104392022	-67.0022489689291
27	2015-12-09 14:25:00	70.3424440976232	50.1161036686972
28	2015-04-20 09:29:07	-175.030683428049	-28.1645071785897
29	2015-01-12 21:10:39	-121.797599019483	27.5861034821719
EOF

cat <<EOF >>/tmp/hdfs_sample/data4.tsv
30	2015-05-18 08:22:21	123.896695543081	-52.3807154526003
31	2014-03-19 16:04:33	-27.0356354769319	64.7607856220566
32	2015-04-03 01:57:44	52.0819870010018	11.5333008067682
33	2014-07-13 11:40:11	-27.5624203216285	-16.8242108402774
34	2015-05-31 00:37:26	95.5484002176672	21.7935285740532
35	2014-08-22 02:25:10	143.46155455336	30.4451290075667
36	2014-11-03 22:48:42	-19.2726380378008	59.6069393004291
37	2015-01-22 10:09:40	-71.7777917068452	-57.4325929395854
38	2014-12-12 10:16:51	4.56945762969553	-64.1478201677091
39	2015-08-14 08:47:10	-65.7431509997696	-55.7506549125537
EOF

cat <<EOF >>/tmp/hdfs_sample/data5.tsv
40	2014-06-13 18:59:25	-149.29481039755	32.6784200617112
41	2015-04-05 18:58:22	63.0127418506891	65.8911071298644
42	2015-04-22 21:49:45	103.007338000461	-73.1178724882193
43	2014-08-27 09:09:31	-156.804968314245	-61.7252860078588
44	2015-11-14 23:49:02	-176.740858806297	16.0975576238707
45	2014-04-14 16:02:32	74.5862430799752	-52.011926479172
46	2015-08-15 07:35:24	178.002978209406	-72.6243476872332
47	2014-05-19 00:57:31	-10.2838515490294	-39.0591608569957
48	2015-12-27 10:47:08	-56.8905417714268	59.4224187871441
49	2014-02-02 01:37:41	154.886480346322	-8.36667434545234
EOF

cat <<EOF >>/tmp/hdfs_sample/data6.tsv
50	2014-05-25 21:17:51	34.8832583706826	15.4320467682555
51	2015-05-06 11:55:13	163.169603794813	51.3611447019503
52	2015-06-07 09:02:52	57.1250683441758	55.4557868163101
53	2014-02-11 08:27:45	71.399189690128	63.8023808621801
54	2015-10-30 01:16:08	65.3754431940615	-67.8222163114697
55	2014-10-17 13:50:52	-5.72856805287302	-38.2253772579134
56	2015-06-07 18:52:34	109.678066670895	9.45049711503088
57	2015-07-30 06:48:59	-162.500891117379	-74.5950505859219
58	2014-09-02 05:26:29	105.874546682462	-79.921473315917
59	2014-06-17 06:58:18	-54.8418476432562	52.118767562788
EOF

cat <<EOF >>/tmp/hdfs_sample/data7.tsv
60	2014-02-14 15:53:51	-28.0847258772701	46.5604267711751
61	2015-01-07 03:06:29	-91.517915809527	48.5319197899662
62	2015-07-11 13:09:30	156.774185942486	59.5437879953533
63	2014-07-29 01:09:13	47.5101707037538	-47.8357703075744
64	2015-11-02 10:24:14	179.23658455722	-74.9274734524079
65	2015-05-08 01:09:34	14.9343992304057	-13.1553641008213
66	2014-12-17 17:11:27	-36.3359011150897	-20.4337734379806
67	2015-05-23 04:10:40	-172.026864979416	-14.8138174484484
68	2015-07-08 02:10:22	143.774749645963	53.1208746484481
69	2014-07-03 20:01:49	-70.3157752286643	67.3648741585203
EOF

cat <<EOF >>/tmp/hdfs_sample/data8.tsv
70	2015-02-12 17:18:54	145.944639304653	-34.1784508456476
71	2014-02-09 05:11:20	-150.564714325592	-41.7358683259226
72	2015-11-20 19:51:03	-31.0141260176897	17.217592925299
73	2015-01-20 22:43:33	164.503724165261	64.0832729125395
74	2015-07-11 02:43:01	-64.6563001256436	-75.3647440532222
75	2014-11-06 18:23:00	-132.903977874666	-48.5656871530227
76	2014-04-21 17:52:52	-45.8872213494033	-38.9192636450753
77	2014-12-26 11:51:25	111.006038747728	38.6447424278595
78	2014-06-14 22:15:21	-177.144772913307	81.3118675537407
79	2015-01-11 21:51:41	122.707031490281	62.8904115897603
EOF

# Put on HDFS, remove local files 

# is the current user in supergroup??

echo "Make home dir on hdfs for ec2-user"
sudo -u hdfs -i hadoop fs -mkdir /user/$USER  #this should be done as hdfs user
sudo -u hdfs -i hadoop fs -chown $USER:supergroup /user/$USER #also done as hdfs user
echo "Make tmp data dir on hdfs; put data"
hadoop fs -mkdir -p /user/$USER/sample
hadoop fs -put /tmp/hdfs_sample/* ${namenode}/user/$USER/sample/
rm -rf /tmp/hdfs_sample

# Run ingest
$GEOMESA_HOME/bin/geomesa ingest -u ${accumulo_user} -p ${accumulo_password} -c ${gm_namespace}.${gm_catalog} -s /tmp/hdfsExample.sft -C /tmp/hdfsExample.convert ${namenode}/user/$USER/sample/*

rm /tmp/hdfsExample*

# Sample export
$GEOMESA_HOME/bin/geomesa export -u ${accumulo_user} -p ${accumulo_password} -c ${gm_namespace}.${gm_catalog} -f hdfsExample
