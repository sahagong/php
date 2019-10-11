#!/bin/bash

# ***************************************************************************************
#  Gabia.Gajet Service Check Script
#  Author   : lsh_at_gabia.com
#  Version  : v1.150507
#  Result   : 0 - Fail
#             1 - OK
#             2 - Unknown
# ***************************************************************************************

DATE=`date +%Y%m%d`
MONTH=`date +%Y%m`

Result_Fail=0
Result_OK=1
Result_Unknown=2
RESULT=${Result_Unknown}
RESULT_V=""

LOGGING_DIR=./logs/$MONTH
LOGGING_FILE=$LOGGING_DIR/U66.SnmpServicecommunityComplexity_RESULT_$DATE.log
CHECK_PLZ=`echo "  check plz.. --> "$LOGGING_FILE`


[ -d ${LOGGING_DIR} ] || mkdir -p ${LOGGING_DIR}
cat /dev/null > "${LOGGING_FILE}"
File_conf=""

# Snmp Service Conf Check
icheck=`ps -ef | grep snmp | grep -v 'grep'| wc -l`


if [ $icheck -eq 0 ]; then


        RESULT="${Result_OK}"
        RESULT_V="- Snmp Service not Running"
else

	if [ -e /etc/snmpd.conf ]; then
		File_conf="/etc/snmpd.conf"
	elif [ -e /etc/snmp/snmpd.conf ]; then
		File_conf="/etc/snmp/snmpd.conf"
	elif [ -e /etc/snmp/conf/snmpd.conf ]; then
		File_conf="/etc/snmp/conf/snmpd.conf"
	fi

	if [ "${File_conf}" == "" ]; then
		# Snmp Service Conf Nothing!
		RESULT=${Result_Unknown}
		RESULT_V=$'-Snmp Service not Exist Conf'
	else
		icheck=`cat ${File_conf} | grep "^com2sec" | grep notConfigUser | grep -E "(public|private)" | wc -l`
		if [ ${icheck} -eq 0 ]; then
			RESULT="${Result_OK}"
			RESULT_V=$'-public, private is nothing'
		else
			RESULT="${Result_Fail}"
			RESULT_V=$'-public, private is exists'
		fi
	fi
fi

## Result Report
echo "# Snmp Service Community Complexity" >> "${LOGGING_FILE}"
echo "${RESULT_V}" >> "${LOGGING_FILE}"
if [ "${File_conf}" != "" ]; then
	echo "-snmp.conf path : ${File_conf}" >> "${LOGGING_FILE}"
	cat ${File_conf} | grep "^com2sec" | grep notConfigUser | grep -E "(public|private)" >> "${LOGGING_FILE}"
fi

# Output
if [ "$1" == "/z" ];then
	cat "${LOGGING_FILE}"
else
	echo "$RESULT"
fi


