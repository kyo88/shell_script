#!/bin/sh

#-------------------------------------------------------------------------

IMPALA_HOST=10.112.21.75
HIVE_HOST=10.112.21.76
HBASE_PUT_HOST01=hduser@10.112.21.45
HBASE_PUT_HOST02=hduser@10.112.21.46
HBASE_SCAN_HOST01=hduser@10.112.21.47
HBASE_SCAN_HOST02=hduser@10.112.21.48
HBASE_QUERRY_FILE=~/hbase_query.qr
IMPALA=0
HIVE=0
HBASE=0
ZK=0
FG="FIRST"

#-------------------------------------------------------------------------


if [ $# == 0 ] ;then
	echo "Usage:./HbaseHiveImpalaFukaTest.sh [hbase_table_name]"
	exit 1
fi

if [ $ZK != 0 ]; then
./ZooKeeperCnnCount.sh&
fi

if [ $2 ]; then
	echo "Set Impala ${2}"
	IMPALA=$2
fi


if [ $3 ]; then
        echo "Set Hive ${3}"
        HIVE=$3
fi

if [ $4 ]; then
        echo "Set Hbase ${4}"
        HBASE=$4
fi

if [ $5 ]; then
        echo "FLAG ${5}"
        FG=$5
fi


log_flag="${FG}_flag_${IMPALA}-${HIVE}-${HBASE}"
echo $log_flag

#exit 1


if [ $IMPALA != 0 ]; then
#Run Impala
impala_log=~/log/impala_log_$(date +"%Y%m%d%H%M%S")
impala_log="${impala_log}_${log_flag}.log"
echo "RUN IMPALA"
echo $impala_log
ssh $IMPALA_HOST "impala-shell -q \" use per_test; \
set PARQUET_COMPRESSION_CODEC=snappy; \
insert overwrite parquet_snappy_result select UV.countrycode from snappy_parquet_uservisits UV join parquet_snappy_rankings_5gb RA on UV.desturl = RA.pageurl group by UV.countrycode; \
\"  > ${impala_log} 2>&1 & "

fi

if [ $HIVE != 0 ]; then

#========================================================Run Hive

hive_log=~/log/hive_log_$(date +"%Y%m%d%H%M%S")
hive_log="${hive_log}_${log_flag}.log"
echo "RUN HIVE"
ssh $HIVE_HOST "hive -e \" use per_test; \
	use per_test; \
set mapred.output.compress=true; \
set mapred.output.compression.type=BLOCK; \
set hive.auto.convert.join=false; \
set mapred.map.output.compression.codec=org.apache.hadoop.io.compress.GzipCodec; \
set mapred.output.compression.codec=org.apache.hadoop.io.compress.GzipCodec; \
insert overwrite table parquet_snappy_result_hive select UV.sourceip from snappy_parquet_uservisits UV join parquet_snappy_rankings_1gb_test RA on UV.desturl = RA.pageurl where UV.sourceip='226.126.17.27';\"  > ${hive_log} 2>&1 &"

fi

if [ $HBASE != 0 ]; then

#========================================================Run HBASE
echo "HBASE"
#create table 
echo "Create table ${1}"
cat <<_EOF_ > ${HBASE_QUERRY_FILE}
disable '${1}'
drop '${1}'
create '${1}', 'test','rs', {SPLITS => ['0ccccccc', '19999998','26666664', '33333330', '3ffffffc', '4cccccc8', '59999994', '66666660', '7333332c']}
exit
_EOF_

cat ${HBASE_QUERRY_FILE}

hbase shell ${HBASE_QUERRY_FILE}

if [ $? != 0 ] ; then 
	echo "create table ${1} FAIL!!!!"
	exit 1
fi

echo "START HBASE LOAD AND SCAN TEST"
#Put 45
hbase_put01_log=/home/hduser/log/hbase_put01_log_$(date +"%Y%m%d%H%M%S")
hbase_put01_log="${hbase_put01_log}_${log_flag}.log"
ssh $HBASE_PUT_HOST01 "cd hbase_test/ ; mvn exec:java -Dexec.mainClass=\"gmo.test.MultiThreadPut\" -Dexec.args=\"${1}\" > ${hbase_put01_log} 2>&1 &"

#put 46
hbase_put02_log=/home/hduser/log/hbase_put02_log_$(date +"%Y%m%d%H%M%S").log
hbase_put02_log="${hbase_put02_log}_${log_flag}.log"
ssh $HBASE_PUT_HOST02 "cd hbase_test/ ; mvn exec:java -Dexec.mainClass=\"gmo.test.MultiThreadPut\" -Dexec.args=\"${1}\"> ${hbase_put02_log} 2>&1 &"

#scan 47
hbase_scan01_log=/home/hduser/log/hbase_scan01_log_$(date +"%Y%m%d%H%M%S").log
hbase_scan01_log="${hbase_scan01_log}_${log_flag}.log"
ssh $HBASE_SCAN_HOST01 "cd hbase_test/ ; mvn exec:java -Dexec.mainClass=\"gmo.test.MultiThreadGet2\" -Dexec.args=\"${1}\"> ${hbase_scan01_log} 2>&1 &"

#scan 48
hbase_scan02_log=/home/hduser/log/hbase_scan02_log_$(date +"%Y%m%d%H%M%S").log
hbase_scan02_log="${hbase_scan02_log}_${log_flag}.log"
ssh $HBASE_SCAN_HOST02 "cd hbase_test/ ; mvn exec:java -Dexec.mainClass=\"gmo.test.MultiThreadGet2\" -Dexec.args=\"${1}\"> ${hbase_scan02_log} 2>&1 &"

fi
