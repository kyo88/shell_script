#!/bin/sh
#-----------------------------------------------------------------------
OOZIE_SERVER="http://cdh-server01.cdh.local:11000/oozie"
#-----------------------------------------------------------------------
echo $1
if [ $# -ne 1 ] ; then
        echo "Usage: <workflow_id>"
        exit 1;
fi

#Get Coordinator_Id of Workflow
COORDINATOR_ID=$(oozie job -oozie ${OOZIE_SERVER} -info ${1} | grep "CoordAction ID:" | awk '{print $3}' | cut -d '@' -f 1 )
if [ $? -ne 0 ]; then
    echo "ERROR:Get Coordinator Id : fail"
    exit 1;
fi
echo $COORDINATOR_ID

#Kill Coordinator
oozie job  -oozie ${OOZIE_SERVER} -kill ${COORDINATOR_ID}
if [ $? -ne 0 ]; then
    echo "ERROR:Kill Coordinator ${COORDINATOR_ID} : fail"
    exit 1;
fi
