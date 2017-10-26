# conformer

Conformer is a tool used for pentesting clients with very common web portals.


conformer v0.4.2
bk201@foofus.net

usage: conformer.sh <HOST_IP/Hostname><:PORT>(optional) <Username or Users_File> 
       <Password<\&par1=val1\&par2=val2>(optional) or Pass_File> <Portal Type> 
       <DISABLE_CHECK>(optional) <DEBUG>(optional) <LOG>(optional)

Portal Types: SonicWallVOffice
              CiscoSSLVPN
              Netscaler
	            OWA2016
              Gmail (Host: mail.google.com) 
              Office365 (Host: outlook.office.com)

conformer.sh <CUSTOM> <BURP_POST_File> <List> 
<String in Response indicating Success> <LOG>(optional) <DEBUG>(optional)

In BURP_POST_FILE, add a @LIST@ to the parameter you want to brute against. 
(e.g. username=admin&password=@LIST@&domain=example)

Type @SAME@ : Password=Username
DISABLE_CHECK : Disable Check if compatible Portal.
DEBUG : outputs HTTP responses to /tmp/password.conformer.debug
LOG : outputs stdout to /tmp/password.conformer.log
