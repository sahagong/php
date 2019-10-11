#!/bin/bash

LANG=C

## Hardware - disk
if [ "$hw_vendor" == "HP" ]; then
  [ -f '/usr/sbin/hpssacli' ] && HP_CMD='/usr/sbin/hpssacli'
  [ -f '/usr/sbin/hpacucli' ] && HP_CMD='/usr/sbin/hpacucli'
  if [ "${HP_CMD}" == "" ]; then
    disk_raid="Unkonwn/HP";
    disk_raid_size="Unkonwn";
    echo "type=disk_array;value=${disk_raid};value2=${disk_raid_size};" > /home/gabia/zabbix/ext/logs/RaidInfo.log
  else
    hp_slot_no=`$HP_CMD ctrl all show status | grep -i slot | awk -F'Slot' '{print$2}' | awk '{print$1}'`;
    $HP_CMD ctrl slot=$hp_slot_no show config | grep . | sed -e "s/^[\t ]*//g" | sed ':a;N;$!ba;s/\n/ /g' | sed -e 's/array/\narray/g' | grep "^array" | while IFS= read line ; do
      disk_raid=`echo $line | awk '{gsub(",", "", $13);print$12" "$13}'`;
      disk_raid_no=`echo $line | awk '{gsub(",", "", $2);print$2}'`;
      echo $line | sed -e 's/physicaldrive/\nphysicaldrive/g' | grep physicaldrive | awk '{gsub(",", "", $7);gsub(",", "", $9);print $7" "$8" "$9}' | while IFS= read disk_raid_size ; do
        echo "type=disk_array;value=${disk_raid}/${disk_raid_no};value2=${disk_raid_size};" > /home/gabia/zabbix/ext/logs/RaidInfo.log
      done
    done
  fi
elif [ "$hw_vendor" == "IBM" ] || [ "$hw_vendor" == "Dell" ]; then
  [ -f '/opt/MegaRAID/MegaCli/MegaCli' ] && IBM_CMD='/opt/MegaRAID/MegaCli/MegaCli'
  [ -f '/opt/MegaRAID/MegaCli/MegaCli64' ] && IBM_CMD='/opt/MegaRAID/MegaCli/MegaCli64'

  if [ "${IBM_CMD}" == "" ]; then
    disk_raid="Unkonwn/IBM";
    disk_raid_size="Unkonwn";
    echo "type=disk_array;value=${disk_raid};value2=${disk_raid_size};" > /home/gabia/zabbix/ext/logs/RaidInfo.log
  else
    ${IBM_CMD} -LDPDinfo -aALL -NoLog | grep . | sed -e "s/^[\t ]*//g" | egrep "^RAID\ Level|^PD|^Raw\ Size" | sed -e 's/\,/\:/g' -e 's/\[/\:/g' |  awk -F':' '{gsub(/[ \t]+/, "", $2);print $1":"$2}' | sed ':a;N;$!ba;s/\n/ /g' | sed -e 's/RAID/\nRAID/g' | grep .  | while IFS= read line ; do
      disk_raid=`echo $line | awk -F':' '{gsub(/Primary-/, "", $2);print$2}' | awk '{print"RAID "$1}'`;
      disk_raid_no="";
      echo $line | sed -e 's/PD/\nPD/g' | grep PD | sed -e 's/\:/ /g' | grep -i size | while IFS= read line2 ; do
        disk_raid_size=`echo ${line2} | tr "[a-z]" "[A-Z]" | awk -F'SIZE' '{gsub(/[ \t]+/, "", $2);gsub("MB", " MB", $2);gsub("GB", " GB", $2);gsub("TB", " TB", $2);print$2}'`;
        if [ "`echo ${line2} | grep -i type | wc -l`" -eq "0" ]; then
          disk_raid_type="unknown";
        else
          disk_raid_type=`echo ${line2} | awk '{print$3}'`;
        fi
        echo "type=disk_array;value=${disk_raid};value2=${disk_raid_type} ${disk_raid_size};" > /home/gabia/zabbix/ext/logs/RaidInfo.log
      done
    done
  fi
else
  disk_raid="Unkonwn/$hw_vendor";
  disk_raid_size="Unkonwn";
  echo "type=disk_array;value=${disk_raid};value2=${disk_raid_size};" > /home/gabia/zabbix/ext/logs/RaidInfo.log
fi

if [ -f "/sbin/parted" ]; then
  icheck=`/sbin/parted -h | grep "\-l" | wc -l`;
  if [ "${icheck}" -eq "1" ]; then
    /sbin/parted -l print | egrep "^Model|^Disk" | sed ':a;N;$!ba;s/\n/ /g' | sed -e 's/Model/\nModel/g' -e 's/Disk/\:Disk/g' | grep . | while IFS= read line ; do
      disk_model=`echo ${line} | awk -F':' '{gsub(/^[ \t]+/, "", $2);gsub(/[ \t]+$/, "", $2); print $2}'`
      disk_model_size=`echo ${line} | awk -F':' '{gsub(/^[ \t]+/, "", $4);gsub(/[ \t]+$/, "", $4); print $4}'`
      echo "type=disk_noarray;value=${disk_model};value2=${disk_model_size};" >> /home/gabia/zabbix/ext/logs/RaidInfo.log
    done
  fi
else
  disk_model="Unkonwn";
  disk_model_size="Unkonwn";
  echo "type=disk_noarray;value=${disk_model};value2=${disk_model_size};" >> /home/gabia/zabbix/ext/logs/RaidInfo.log
fi


