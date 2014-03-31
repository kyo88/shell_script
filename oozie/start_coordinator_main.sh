#!/bin/sh
#------------------------------------------------------------------------------
JOBTRACKER="logicaljt:8021"
NAMENODE="hdfs://nameservice1"
END_TIME="2050-10-30T00:00+0900"
CONCURRENCY=1
PREQUENCY_TIME=5
APP_PATH="${NAMENODE}/PurchaseSegment/CoordinatorDir/"
WORKFLOW_PATH="${NAMENODE}/PurchaseSegment/CoordinatorDir/"
JOB_CONF_PATH="/data/purchase_segment/job.properties"
OOZIE_SERVER="http://cdh-server01.cdh.local:11000/oozie"
#------------------------------------------------------------------------------

#Calculator start time for coordinator
HOUR=$(date +"%H")
#HOUR=03
if [ "$HOUR" -gt 4 ]; then
    START_TIME="$(date +"%Y-%m-%dT" -d "-1 day ago")04:00+0900"
else
    START_TIME="$(date +"%Y-%m-%dT")04:00+0900"
fi

#Run Coordinator
RESULT=$(oozie job -oozie ${OOZIE_SERVER} -config ${JOB_CONF_PATH} -Dstart="${START_TIME}" \
-DnameNode=${NAMENODE} -DjobTracker=${JOBTRACKER} \
-Doozie.coord.application.path=${APP_PATH} -Dend="${END_TIME}" \
-Dconcurrency=${CONCURRENCY} -DworkflowAppUri=${WORKFLOW_PATH} -run | grep "job:" | awk '{ print $2}' )

if [ $? -ne 0 ] ; then
        echo "ERROR:START COORDINATOR FAIL"
        exit 1;
else
        echo "Start Coordinator id=${RESULT} at $(date +"%H:%M:%S %Y%m%d")"
fi
