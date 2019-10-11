#!/bin/bash
LANG=C
export LANG

DATE=`date +%Y%m%d`
MONTH=`date +%Y%m`

AppName="G12.Apache_Maximum_Client_Check"
Result_Fail=0
Result_OK=1
Result_Unknown=2
RESULT=${Result_Unknown}
RESULT_V=""

LOGGING_DIR=./logs/$MONTH
LOGGING_FILE=$LOGGING_DIR/${AppName}__RESULT_$DATE.log
CHECK_PLZ=`echo "  check plz.. --> "$LOGGING_FILE`

[ -d ${LOGGING_DIR} ] || mkdir -p ${LOGGING_DIR}
cat /dev/null > "${LOGGING_FILE}" 2>&1


score=0
icheck=0
jcheck=0
service=""

echo "# Apache Maximum Client Check" >> "${LOGGING_FILE}" 2>&1

if [ `ps -ef | egrep -i "(httpd|apache)" | grep -v "org.apache" | grep -v 'egrep' | wc -l` -eq 0 ]
then
  echo "RESULT : INTERVIEW " >> "${LOGGING_FILE}" 2>&1
  echo " " >> "${LOGGING_FILE}" 2>&1
  echo " Not Running httpd/apache " >> "${LOGGING_FILE}" 2>&1
else


ps aufx | egrep "(httpd|apache)" | grep -v '\\' | grep -v "org.apache" |  awk '{print$11" "$2}' | while IFS= read LINE
do
  apache_bin=`echo $LINE | awk '{print$1}'`;
  apachectl_bin=`echo $LINE | awk '{print$1}' | sed -e 's/apache2/apachectl/g' -e 's/httpd/apachectl/g'`;
  apache_pid=`echo $LINE | awk '{print$2}'`;
  if [ -f "${apache_bin}" ]
  then
    let icheck++
    HTTPD_ROOT=`${apachectl_bin} -V | grep "HTTPD_ROOT" | awk -F'=' '{gsub(/^[ \t]+/, "", $2); print $2}' | sed -e 's/\"//g'`;
    SERVER_CONFIG_FILE=`${apachectl_bin} -V | grep "SERVER_CONFIG_FILE" | cut -d "=" -f 2 | sed -e 's/\"//g'`;  
    HTTPD_CONF=""
    apache_maxclients=256
    if [ -f "${HTTPD_ROOT}/${SERVER_CONFIG_FILE}" ]
    then
      HTTPD_CONF="${HTTPD_ROOT}/${SERVER_CONFIG_FILE}"       
      apache_maxclients=`awk -F'#' '{print$1}' "${HTTPD_CONF}" | awk 'NF' | egrep -i "(prefork|MaxClients)" | grep -a1 -i "prefork" | tail -n 1 | awk '{print$2}'`
    fi
    if [ -f "${HTTPD_ROOT}/conf.d/*.conf" ] && [ `echo ${apache_maxclients} | wc -l ` -eq 0 ]
    then
      HTTPD_CONF="${HTTPD_ROOT}/conf.d/*.conf"
      apache_maxclients=`awk -F'#' '{print$1}' "${HTTPD_CONF}" | awk 'NF' | egrep -i "(prefork|MaxClients)" | grep -a1 -i "prefork" | tail -n 1 | awk '{print$2}'`
    fi
    if [ -f "${HTTPD_ROOT}/conf/extra/*.conf" ] && [ `echo ${apache_maxclients} | wc -l ` -eq 0 ]
    then
      HTTPD_CONF="${HTTPD_ROOT}/conf/extra/*.conf"
      apache_maxclients=`awk -F'#' '{print$1}' "${HTTPD_CONF}" | awk 'NF' | egrep -i "(prefork|MaxClients)" | grep -a1 -i "prefork" | tail -n 1 | awk '{print$2}'`
    fi

    if [[ ${apache_maxclients} =~ '^-?[0-9]+$' ]]
    then
      if [ "${apache_maxclients}" -gt 256 ]
      then
        echo "RESULT : OK" >> "${LOGGING_FILE}" 2>&1
        echo " " >> "${LOGGING_FILE}" 2>&1
        echo "- httpd.conf : ${HTTPD_CONF} " >> "${LOGGING_FILE}" 2>&1
        echo "# httpd.conf grep MaxClients"  >> "${LOGGING_FILE}" 2>&1
        awk -F'#' '{print$1}' ${HTTPD_CONF} | awk 'NF' | grep -i "MaxClients" >> "${LOGGING_FILE}" 2>&1
      else
        if [ "${score}" -eq 0 ]
        then
          echo "RESULT : NO " >> "${LOGGING_FILE}" 2>&1
        fi
        echo " " >> "${LOGGING_FILE}" 2>&1
        echo "- httpd.conf : ${HTTPD_CONF} " >> "${LOGGING_FILE}" 2>&1
        echo "# httpd.conf grep MaxClients"  >> "${LOGGING_FILE}" 2>&1
        awk -F'#' '{print$1}' ${HTTPD_CONF} | awk 'NF' | grep -i "MaxClients" >> "${LOGGING_FILE}" 2>&1
        let score++
      fi
    fi
  fi
done
fi


if [ "${score}" -eq 0 ]
then
        RESULT="${Result_OK}"
else
        RESULT="${Result_Fail}"
fi

# Output
if [ "$1" == "/z" ];then
        cat "${LOGGING_FILE}"
else
        echo "$RESULT"
fi

