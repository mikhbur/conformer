# conformer

Conformer is a tool used for pentesting clients with very common web portals.

conformer v0.5.1
bk201@foofus.net

usage: conformer.sh <HOST_IP/Hostname><:PORT>(optional) <Username or Users_File> 
       <Password<\&par1=val1\&par2=val2>(optional) or Pass_File> <Portal Type> 
       <DISABLE_CHECK>(optional) <DEBUG=file>(optional) <LOG=file>(optional)
       <THREAD=n>(optional)

Portal Types: SonicWallVOffice
              CiscoSSLVPN
              Netscaler
	      OWA (versions 2013/2016)
              Gmail (Host: mail.google.com)
              Office365 (Host: outlook.office.com)
              PaloAlto (GlobalProtect)
              SharePoint
              AUTO (Attempt autodetect module)

Type @SAME@ : Password=Username
DISABLE_CHECK : Disable Check if compatible Portal.
DEBUG : outputs HTTP responses to file
LOG : outputs stdout to file
THREAD : Threading of POST requests to server

syntax examples.
conformer.sh domain.example.com username ~/Desktop/passwords CiscoSSLVPN
conformer.sh domain.example.com ~/Desktop/users ~/Desktop/passwords OWA THREAD=10
conformer.sh domain.example.com username password123 Gmail LOG=~/Desktop/log DEBUG=~/Desktop/debug
conformer.sh domain.example.com ~/Desktop/users Password1 Netscaler DISABLE_CHECK DEBUG=~/Desktop/debug
