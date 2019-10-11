#!/bin/bash


DATE=`date +%Y%m%d`
MONTH=`date +%Y%m`


Result_Fail=0
Result_OK=1
Result_Unknown=2

LOGGING_DIR=./logs/$MONTH


cd /home/admin/1.local
case "$1" in
	"admin.status.diskfree")
		cd ./1.monthly_check/1.DISK_free
		LOGGING_FILE=$LOGGING_DIR/1.DISK_free_check_RESULT_$DATE.log
		[ -f $LOGGING_FILE ] && rm -f $LOGGING_FILE

		icheck=`./DISK_free_check.sh | grep "RESULT: O" | wc -l`
		if [ "${icheck}" -eq 1 ];then
			echo ${Result_OK}
		else
			echo ${Result_Fail}
		fi
		;;
	"admin.status.diskfree.detail")
          	cd ./1.monthly_check/1.DISK_free
		LOGGING_FILE=$LOGGING_DIR/1.DISK_free_check_RESULT_$DATE.log
		[ -f $LOGGING_FILE ] && iconv -f CP949 -t UTF-8 $LOGGING_FILE
		;;

	"admin.status.filesystem")
		cd ./1.monthly_check/2.FileSystem_Crash
		LOGGING_FILE=$LOGGING_DIR/2.FileSystem_Crash_RESULT_$DATE.log
		[ -f $LOGGING_FILE ] && rm -f $LOGGING_FILE

		icheck=`./FileSystem_Crash.sh | grep "RESULT: O" | wc -l`
		if [ "${icheck}" -eq 1 ];then
			echo ${Result_OK}
		else
			echo ${Result_Fail}
		fi
		;;
	"admin.status.filesystem.detail")
		cd ./1.monthly_check/2.FileSystem_Crash
		LOGGING_FILE=$LOGGING_DIR/2.FileSystem_Crash_RESULT_$DATE.log
		[ -f $LOGGING_FILE ] && iconv -f CP949 -t UTF-8 $LOGGING_FILE
		;;

	"admin.status.raid")
		cd ./1.monthly_check/3.RAID_fail
                LOGGING_FILE=$LOGGING_DIR/3.RAID_Fail_RESULT_$DATE.log
                [ -f $LOGGING_FILE ] && rm -f $LOGGING_FILE

		icheck=`./RAID_fail.sh | grep "RESULT: O" | wc -l`
		if [ "${icheck}" -eq 1 ];then
			echo ${Result_OK}
		else
			echo ${Result_Fail}
		fi
		;;
	"admin.status.raid.detail")
		cd ./1.monthly_check/3.RAID_fail
		LOGGING_FILE=$LOGGING_DIR/3.RAID_Fail_RESULT_$DATE.log
		[ -f $LOGGING_FILE ] && iconv -f CP949 -t UTF-8 $LOGGING_FILE 
		;;

	"admin.status.localbackup")

           mdb_check=`ps -ef |grep -i mysql |grep -v 'grep' | grep -v 'bb-mysql'|wc -l`
           ora_check=`ps -ef |grep -i oracle |grep -v 'grep'  |wc -l`


		if [ $mdb_check -eq 0 ] && [ $ora_check -eq 0 ]
		then

				echo ${Result_OK}

		else
			cd ./1.monthly_check/4.Data_backup
			LOGGING_FILE=$LOGGING_DIR/4.Data_backup_check_RESULT_$DATE.log
			[ -f $LOGGING_FILE ] && rm -f $LOGGING_FILE 

			icheck=`./Data_backup.sh | grep "RESULT: O" | wc -l`
			if [ "${icheck}" -eq 1 ];then
				echo ${Result_OK}
			else
				echo ${Result_Fail}
			fi

		fi
		;;
	"admin.status.localbackup.detail")
		cd ./1.monthly_check/4.Data_backup
		LOGGING_FILE=$LOGGING_DIR/4.Data_backup_check_RESULT_$DATE.log
		[ -f $LOGGING_FILE ] && iconv -f CP949 -t UTF-8 $LOGGING_FILE
		;;

	"admin.status.arp")
		cd ./2.quarterly_check/1.ARP_Static
		LOGGING_FILE=$LOGGING_DIR/1.ARP_Static_RESULT_$DATE.log
		[ -f $LOGGING_FILE ] && rm -f $LOGGING_FILE

		icheck=`./ARP_Static.sh | grep "RESULT: O" | wc -l`
		if [ "${icheck}" -eq 1 ];then
			echo ${Result_OK}
		else
			echo ${Result_Fail}
		fi
		;;
	"admin.status.arp.detail")
		cd ./2.quarterly_check/1.ARP_Static
		LOGGING_FILE=$LOGGING_DIR/1.ARP_Static_RESULT_$DATE.log
		[ -f $LOGGING_FILE ] && iconv -f CP949 -t UTF-8 $LOGGING_FILE 
		;;

	"admin.status.serverlog")
		cd ./2.quarterly_check/2.LOG_check
		LOGGING_FILE=$LOGGING_DIR/2.LOG_CHECK_RESULT_$DATE.log
		[ -f $LOGGING_FILE ] && rm -f $LOGGING_FILE

		icheck=`./LOG_check.sh | grep "RESULT: O" | wc -l`
		if [ "${icheck}" -eq 1 ];then
			echo ${Result_OK}
		else
			echo ${Result_Fail}
		fi
		;;
	"admin.status.serverlog.detail")
		cd ./2.quarterly_check/2.LOG_check
		LOGGING_FILE=$LOGGING_DIR/2.LOG_CHECK_RESULT_$DATE.log
		[ -f $LOGGING_FILE ] && iconv -f CP949 -t UTF-8 $LOGGING_FILE 
		;;

	"admin.status.bbrun")
		cd ./2.quarterly_check/3.BB_install_runing
		LOGGING_FILE=$LOGGING_DIR/3.BB_run_install_check_RESULT_$DATE.log
		[ -f $LOGGING_FILE ] && rm -f $LOGGING_FILE
		
		icheck=`./BB_install_runing.sh | grep "RESULT: O" | wc -l`
		if [ "${icheck}" -eq 1 ];then
			echo ${Result_OK}
		else
			echo ${Result_Fail}
		fi
		;;
	"admin.status.bbrun.detail")
		cd ./2.quarterly_check/3.BB_install_runing
		LOGGING_FILE=$LOGGING_DIR/3.BB_run_install_check_RESULT_$DATE.log
		[ -f $LOGGING_FILE ] && iconv -f CP949 -t UTF-8 $LOGGING_FILE
		;;

	"admin.status.bblimit")
		cd ./2.quarterly_check/4.BB_limit_check
		LOGGING_FILE=$LOGGING_DIR/4.BB_Limit_check_RESULT_$DATE.log
		[ -f $LOGGING_FILE ] && rm -f $LOGGING_FILE

		icheck=`./BB_limit_check.sh | grep "RESULT: O" | wc -l`
		if [ "${icheck}" -eq 1 ];then
			echo ${Result_OK}
		else
			echo ${Result_Fail}
		fi
		;;
	"admin.status.bblimit.detail")
		cd ./2.quarterly_check/4.BB_limit_check
		LOGGING_FILE=$LOGGING_DIR/4.BB_Limit_check_RESULT_$DATE.log
		[ -f $LOGGING_FILE ] && iconv -f CP949 -t UTF-8 $LOGGING_FILE 
		;;

	"admin.status.agent")
		cd ./2.quarterly_check/5.admin_Agent_check
		LOGGING_FILE=$LOGGING_DIR/5.admin_Agent_check_RESULT_$DATE.log
		[ -f $LOGGING_FILE ] && rm -f $LOGGING_FILE

		icheck=`./admin_Agent_check.sh | grep "RESULT: O" | wc -l`
		if [ "${icheck}" -eq 1 ];then
			echo ${Result_OK}
		else
			echo ${Result_Fail}
		fi
		;;
	"admin.status.agent.detail")
		cd ./2.quarterly_check/5.admin_Agent_check
		LOGGING_FILE=$LOGGING_DIR/5.admin_Agent_check_RESULT_$DATE.log
		[ -f $LOGGING_FILE ] && iconv -f CP949 -t UTF-8 $LOGGING_FILE 
		;;

	"admin.status.LockedAccountLimit")
		icheck=`ps -ef | grep fail2ban-server | grep -v "grep" | wc -l`
		if [ "${icheck}" -eq 1 ];then
			echo ${Result_OK}
		else
			echo ${Result_Fail}
		fi
		;;
	"admin.status.LockedAccountLimit.detail")
		icheck=`ps -ef | grep fail2ban-server | grep -v "grep" | wc -l`
		if [ "${icheck}" -eq 1 ];then
			ps -ef | grep fail2ban-server | grep -v "grep"
		else
			echo "Not running fail2ban"
		fi
		;;

	 *)
		echo ${Result_Unknown} ;;
esac
exit

