#!/bin/bash

Check_Any(){
check_Portal=$(wget --timeout=4 -qO- https://$1 --no-check-certificate);

isPortal=false;

if [[ $(echo "$check_Portal" | grep -i 'method="post"') ]] ; then
	isPortal=true;
else
	echo "No WebPortal Detected. Check the URL, and try again...";
	exit 1;
fi

POST=$(curl -i -s -k  -X $'POST' \
    -H $'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0' -H $'Referer: https://'$1 -H $'Content-Type: application/x-www-form-urlencoded' \
    -b $'PHPSESSID=9e7196647c59703b404598304f36e9ff' \
    --data-binary $'prot=https%3A&server='$1'&inputStr=&action=getsoftware&user='$line'&passwd='$pass'&ok='$LoginPar'' \
    $'https://'$1'/global-protect/login.esp');

IFS=$'\n';
for line in $(wget --timeout=4 -qO- https://$1 --no-check-certificate | grep "<input"); do

	if [[ $(echo "$line" | grep "name=") ]] ; then
		printf $line | sed 's/.*name="//g' | sed 's/".*//g';
		if [[ $(echo "$line" | grep "value=") ]] ; then
			echo $line | sed 's/.*value="/=/g' | sed 's/".*//g';
		else
			echo "=";
		fi

	fi

done

echo $Input_opt;

}

POST_Any(){




}
