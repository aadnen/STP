#!/bin/sh

ELEMENT=STP1
STP=$STP_NAME

AMTP_USER=root
AMTP_GROUP=root

AMTP_HOME=/opt/stp
BIN_DIR=${AMTP_HOME}/lib
CONFIG_FILE=${AMTP_HOME}/config/${ELEMENT}.xml
LICENCE_FILE=${AMTP_HOME}/config/Licence${STP}.cfg
echo $LICENCE_FILE
LOG_FILE=${AMTP_HOME}/log/${ELEMENT}_

mkdir /root/.snmp
cp /opt/amtp-stp.conf /root/.snmp/

export PATH="${BIN_DIR}:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin"
export LD_LIBRARY_PATH="${AMTP_HOME}/lib:${AMTP_HOME}/baselib:${BIN_DIR}"
export SNMP_PERSISTENT_DIR="/root/.snmp"

if [ -n $POINT_CODE ]
then
   echo "Point code is $POINT_CODE"
else
   echo "Point code not set"
fi

if [ -n $STP_IP ]
then
   echo "STP Ip address is $STP_IP"
else
   echo "STP Ip address not set"
fi

RCVTY=$POINT_CODE
RCFKT=$(($RCVTY+1))
echo $RCVTY
echo $RCFKT

sed -i -e 's/PCNODE/'$POINT_CODE'/g' ${AMTP_HOME}/config/networkelement.csv
sed -i -e 's/NODEIP/'$STP_IP'/g' ${AMTP_HOME}/config/networkelement.csv
sed -i -e 's/RCVTY/'$RCVTY'/g' ${AMTP_HOME}/config/linksetstp1.csv
sed -i -e 's/RCFKT/'$RCFKT'/g' ${AMTP_HOME}/config/linksetstp1.csv
sed -i -e 's/PCNODE/'$POINT_CODE'/g' ${AMTP_HOME}/config/linksetstp1.csv
sed -i -e 's/PCNODE/'$POINT_CODE'/g' ${AMTP_HOME}/config/sccpstp1.csv

#Added for emergency link
#STP are client in fkt, servers in par
if [ $POINT_CODE -eq "31" ]
then
	IS_CLIENT=true
	IS_SERVER=false
	POINT_CODE_REMOTE=34
	IP_REMOTE=10.75.40.227
	HLRHPEVTY1=10.60.40.157
	HLRHPEVTY2=10.60.40.161
	HLRHPEFKT1=10.60.40.158
	HLRHPEFKT2=10.60.40.162
fi
if [ $POINT_CODE -eq "41" ]
then
        IS_CLIENT=true
        IS_SERVER=false
        POINT_CODE_REMOTE=44
        IP_REMOTE=10.75.41.7
        HLRHPEVTY1=10.60.40.157
        HLRHPEVTY2=10.60.40.161
        HLRHPEFKT1=10.60.40.158
        HLRHPEFKT2=10.60.40.162
fi
if [ $POINT_CODE -eq "34" ]
then
        IS_CLIENT=false
        IS_SERVER=true
        POINT_CODE_REMOTE=31
        IP_REMOTE=10.70.40.54
        HLRHPEVTY1=10.60.40.57
        HLRHPEVTY2=10.60.40.61
        HLRHPEFKT1=10.60.40.58
        HLRHPEFKT2=10.60.40.62
fi
if [ $POINT_CODE -eq "44" ]
then
        IS_CLIENT=false
        IS_SERVER=true
        POINT_CODE_REMOTE=41
        IP_REMOTE=10.70.41.218
        HLRHPEVTY1=10.60.40.57
        HLRHPEVTY2=10.60.40.61
        HLRHPEFKT1=10.60.40.58
        HLRHPEFKT2=10.60.40.62
fi

sed -i -e 's/PCRNODE/'$POINT_CODE_REMOTE'/g' ${AMTP_HOME}/config/networkelement.csv
sed -i -e 's/NODERIP/'$IP_REMOTE'/g' ${AMTP_HOME}/config/networkelement.csv
sed -i -e 's/HLRHPEVTY1/'$HLRHPEVTY1'/g' ${AMTP_HOME}/config/networkelement.csv
sed -i -e 's/HLRHPEVTY2/'$HLRHPEVTY2'/g' ${AMTP_HOME}/config/networkelement.csv
sed -i -e 's/HLRHPEFKT1/'$HLRHPEFKT1'/g' ${AMTP_HOME}/config/networkelement.csv
sed -i -e 's/HLRHPEFKT2/'$HLRHPEFKT2'/g' ${AMTP_HOME}/config/networkelement.csv
sed -i -e 's/PCRNODE/'$POINT_CODE_REMOTE'/g' ${AMTP_HOME}/config/linksetstp1.csv
sed -i -e 's/IS_CLIENT/'$IS_CLIENT'/g' ${AMTP_HOME}/config/linksetstp1.csv
sed -i -e 's/IS_CLIENT/'$IS_CLIENT'/g' ${AMTP_HOME}/config/STP1.xml
sed -i -e 's/IS_SERVER/'$IS_SERVER'/g' ${AMTP_HOME}/config/STP1.xml
#

ulimit -c unlimited
ulimit -s 2800

#syslog
yes | cp -f /opt/rsyslog.conf /etc/
/usr/sbin/rsyslogd -n &
ps -ef | grep syslog

cd ${BIN_DIR}

echo "module role : ${ELEMENT}"
echo "Starting AMTP module ${ELEMENT} with config $CONFIG_FILE"

${BIN_DIR}/jormungand -config ${CONFIG_FILE} -licence ${LICENCE_FILE} -snmp amtp-stp -log ${LOG_FILE}
