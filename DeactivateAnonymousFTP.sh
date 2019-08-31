#!/bin/bash
DATE=`date +%Y%m%d`
MONTH=`date +%Y%m`

AppName="U37_Deactivate_Anonymous_FTP"
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

echo "# FTP Servive check" >> "${LOGGING_FILE}" 2>&1

if [ `ps -ef | grep ftp | egrep -v "grep" | wc -l` -eq 0 ]
then
   echo "RESULT : OK (Not applicable to this action because of the FTP service) " >> "${LOGGING_FILE}" 2>&1
else

    if [ `ps -ef | grep -i proftp | egrep -v "grep" | wc -l` -gt 0 ]
    then
	PID=`ps -ef | grep -i proftp | egrep -v "grep" |awk -F" " {'print $2}'`
	EXE_FILE=`ls -l /proc/$PID/ |grep exe |awk -F">" '{print $2}' | sed 's/ //g'`

	if [ -f $EXE_FILE ]
	then


		if [ -f /etc/proftpd.conf ]
    		then
      			if [ `cat /etc/proftpd.conf | grep -i "<Anonymous" |grep -v "<Anonymous" | wc -l` -gt 0 ]
      			then
        				if [ "${score}" -eq 0 ]
        				then

          					echo "RESULT : NO " >> "${LOGGING_FILE}" 2>&1
        				fi
        			echo "/etc/proftpd.conf enable anonymous FTP " >> "${LOGGING_FILE}" 2>&1
    	    			let score++
      			fi
    		fi


    		if [ -f /etc/proftp/proftpd.conf ]
    			then
      			if [ `cat /etc/proftp/proftpd.conf | grep -i "<Anonymous" |grep -v "<Anonymous" | wc -l` -gt 0 ]
      			then

        				if [ "${score}" -eq 0 ]
        				then
          					echo "RESULT : NO " >> "${LOGGING_FILE}" 2>&1
        				fi
        			RESULT_V="/etc/proftp/proftpd.conf enable anonymous FTP "
        			let score++
      			fi
    		fi

	fi
fi


  if [ `ps -ef | grep vsftp | egrep -v "grep" | wc -l` -gt 0 ]
  then
    if [ -f /etc/vsftpd/vsftpd.conf ]
    then
      if [ `cat /etc/vsftpd/vsftpd.conf | awk -F'#' '{print$1}' | grep -i "^anonymous_enable" | awk -F'=' '{print$2}' | grep -i -v "no" | wc -l` -gt 0 ]
      then
        if [ "${score}" -eq 0 ]
        then
          echo "RESULT : NO " >> "${LOGGING_FILE}" 2>&1
        fi
        echo "/etc/vsftpd/vsftpd.conf enable anonymous FTP " >> "${LOGGING_FILE}" 2>&1
        let score++
      fi
    fi

    if [ -f /etc/vsftpd.conf ]
    then
      if [ `cat /etc/vsftpd.conf | awk -F'#' '{print$1}' | grep -i "^anonymous_enable" | awk -F'=' '{print$2}' | grep -i -v "no" | wc -l` -gt 0 ]
      then
        if [ "${score}" -eq 0 ]
        then
          echo "RESULT : NO " >> "${LOGGING_FILE}" 2>&1
        fi
        RESULT_V="/etc/vsftpd.conf enable anonymous FTP "
        let score++
      fi
    fi
  fi

  if [ "${score}" -eq 0 ]
  then
    echo "RESULT : OK (anonymous FTP disabled) " >> "${LOGGING_FILE}" 2>&1
  fi

fi


if [ -f /etc/vsftpd/vsftpd.conf ]
then
  echo " " >> "${LOGGING_FILE}" 2>&1
  echo "# cat /etc/vsftpd/vsftpd.conf grep anonymous_enable" >> "${LOGGING_FILE}" 2>&1
  cat /etc/vsftpd/vsftpd.conf | grep -i "anonymous_enable" >> "${LOGGING_FILE}" 2>&1
fi

if [ -f /etc/vsftpd.conf ]
then
  echo " " >> "${LOGGING_FILE}" 2>&1
  echo "# cat /etc/vsftpd.conf grep anonymous_enable" >> "${LOGGING_FILE}" 2>&1
  cat /etc/vsftpd.conf | grep -i "anonymous_enable" >> "${LOGGING_FILE}" 2>&1
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

