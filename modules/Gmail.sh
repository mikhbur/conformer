#!/bin/bash

POST_Gmail(){
		POST=$(curl -u "$line":"$pass" --silent "https://mail.google.com/mail/feed/atom");
		#If Logging is enabled loop userlist
		if [[ $(echo "$5" | tr '[:upper:]' '[:lower:]') == "debug" ]] || [[ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "debug" ]] || [[ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "debug" ]]; then
			echo "host:mail.google.com username:$line password:$pass" >> /tmp/conformer.debug;
			echo "" >> /tmp/conformer.debug;			
			echo "$POST" >> /tmp/conformer.debug;
			echo "" >> /tmp/conformer.debug;	
			echo "" >> /tmp/conformer.debug;	
			echo "-------------------------------------------------------------" >> /tmp/conformer.debug;	
		fi
			#checks reply
			if [[ $POST == *"<title>Gmail - Inbox for"* ]]; then
				echo "	$line:$pass:**Success**";
			if [[ $(echo "$5" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "log" ]]; then
				echo "	$line:$pass:**Success**" >> /tmp/conformer.log;
			fi
			elif [[ $POST != *"<title>Gmail - Inbox for"* ]] && [[ $POST != *"<TITLE>Unauthorized</TITLE>"* ]]; then
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
