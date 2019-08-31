#!/bin/bash
DATE=`date +%Y%m%d`
MONTH=`date +%Y%m`

AppName="U15.SetSessionTimeout"
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

echo "# /etc/profile File check" >> "${LOGGING_FILE}" 2>&1

if [ -f /etc/profile ]
then
  icheck=`cat /etc/profile | awk -F'#' '{print$1}' | grep -i "TMOUT"  | awk -F"=" '{ print $2 }' | wc -l`
  PTIMEOUT=`cat /etc/profile | awk -F'#' '{print$1}' | grep -i "TMOUT" | awk -F"=" '{ print $2 }'`
  if [ "${icheck}" -eq 0 ]
  then
    echo "RESULT : NO ( not set of Timeout )" >> "${LOGGING_FILE}" 2>&1
    let score++
  else
    if [ "${PTIMEOUT}" -le 600 ]
    then
      echo "RESULT : OK" >> "${LOGGING_FILE}" 2>&1
    else
      echo "RESULT : NO ( Timeout set under than 600 )" >> "${LOGGING_FILE}" 2>&1
      echo " " >> "${LOGGING_FILE}" 2>&1
      cat /etc/profile | awk -F'#' '{print$1}' | grep -i "TMOUT" >> "${LOGGING_FILE}" 2>&1
      let score++
    fi
  fi
else
  echo "/etc//etc/profile file is not found"  >> "${LOGGING_FILE}" 2>&1
  let score++
fi


if [ -f /etc/profile ]
then
  echo " " >> "${LOGGING_FILE}" 2>&1
  echo "# cat /etc/profile grep TMOUT" >> "${LOGGING_FILE}" 2>&1
  cat /etc/profile | grep -i "TMOUT" >> "${LOGGING_FILE}" 2>&1
fi

if [ -f /etc/csh.login ]
then
  echo " " >> "${LOGGING_FILE}" 2>&1
  echo "# cat /etc/csh.login grep autologout" >> "${LOGGING_FILE}" 2>&1
  cat /etc/csh.login | grep -i "autologout" >> "${LOGGING_FILE}" 2>&1
fi

if [ -f /etc/csh.cshrc ]
then
  echo " " >> "${LOGGING_FILE}" 2>&1
  echo "# cat /etc/csh.cshrc grep autologout" >> "${LOGGING_FILE}" 2>&1
  cat /etc/csh.cshrc | grep -i "autologout" >> "${LOGGING_FILE}" 2>&1
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

