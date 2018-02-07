#!/bin/bash

source ../conformer.sh &> /dev/null;

check_CiscoSSLVPN_auto(){
	check_Portal=$(wget --timeout=4 -qO- https://$1/+CSCOE+/logon.html --no-check-certificate);
	if [ "$(echo "$check_Portal" | grep 'name="username"')" ] && [ "$(echo "$check_Portal" | grep 'name="password"')" ] && [ "$(echo "$check_Portal" | grep 'name="Login"')" ] ; then
		Portal_Type="CiscoSSLVPN";
	else	
		#Check for older version 2010?
		check_Portal=$(wget --timeout=4 -qO- https://$1/webvpn.html --no-check-certificate);
		if [ "$(echo "$check_Portal" | grep "username")" ] && [ "$(echo "$check_Portal" | grep "password")" ] && [ "$(echo "$check_Portal" | grep "Login")" ] ; then
			Portal_Type="CiscoSSLVPN";
		else	
			:
		fi
	fi
}

check_Netscaler_auto(){
	check_Portal=$(wget --timeout=4 -qO- https://$1/vpn/index.html --no-check-certificate);
	if [ "$(echo $check_Portal | grep '<title>Netscaler Gateway</title>' )" ] ; then
		Portal_Type="Netscaler";
	else
		:
	fi
}

check_OWA2016_auto(){
	check_Portal=$(wget --timeout=4 -qO- https://$1/owa/auth/logon.aspx --no-check-certificate);
	if [ "$(echo $check_Portal | grep '2003-2006 Microsoft Corporation' )" ] ; then
		Portal_Type="OWA"
	else
		:
	fi
}

check_PaloAlto_auto(){
	check_Portal=$(wget --timeout=4 -qO- https://$1/global-protect/login.esp --no-check-certificate);
	if [[ "$(echo $check_Portal | grep "GlobalProtect Portal")" ]] ; then
		Portal_Type="PaloAlto"
	else	
		:
	fi
}

check_SharePoint_auto(){

	check_Portal=$(wget --timeout=4 -qO- https://$1/_forms/default.aspx --no-check-certificate);
	if [ "$(echo $check_Portal | grep "Microsoft SharePoint" )" ] ; then
		Portal_Type="SharePoint"
	else	
		:
	fi
}

check_SonicWallVOffice_auto(){
	check_Portal=$(wget --timeout=4 -qO- https://$1/cgi-bin/welcome --no-check-certificate);
	if [ "$(echo $check_Portal | grep 'VirtualOffice' )" ] ; then
		Portal_Type="SonicWallVOffice"
	else
		:
	fi

}

check_Start(){
	Portal_Type="unknown";
	check_CiscoSSLVPN_auto "$1";
	check_Netscaler_auto "$1";
	check_OWA2016_auto "$1";
	check_PaloAlto_auto "$1";
	check_SharePoint_auto "$1";
	check_SonicWallVOffice_auto "$1";

	if [ "$Portal_Type" != "unknown" ] ; then
		parameter_check "$1" "$2" "$3" "$Portal_Type" "$5" "$6" "$7" "$8";
	else
		echo "Could not determine Portal Type.";
		echo "Exiting...";
		exit 1
	fi

	
}



