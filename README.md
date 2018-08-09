# conformer

Conformer is a penetration testing tool, mostly used for external assessments to perform password based attacks against common webforms. Conformer was created from a need for password guessing against new web forms, without having to do prior burp work each time, and wanting to automate such attacks. Conformer is modular with many different parameters and options that can be customized to make for a powerful attack. Conformer has been used in countless assessments to obtain valid user credentials for accessing the internal environment through VPN, other internal resources or data to further the assessment.

conformer v0.5.9
bk201@foofus.net

usage: conformer.sh <HOST_IP/Hostname><:PORT>(optional) <Username or Users_File> 
       <Password<\&par1=val1\&par2=val2>(optional) or Pass_File> <Portal Type> 
       <DISABLE_CHECK>(optional) <DEBUG=file>(optional) <LOG=file>(optional)
       <THREAD=n>(optional)

Portal Types: SonicWallVOffice
              CiscoSSLVPN
              Netscaler
	      OWA (versions 2013/2016)
              Gmail (Host: mail.google.com) (Google throttling authentication attempts)
              Office365 (Host: outlook.office.com)
              PaloAlto (GlobalProtect)
              SharePoint
              XenMobile
              XenApp (Incomplete)
              Okta (Incomplete)
              AUTO (Attempt autodetect module)
              --------------------------------
              SMB (Windows Auth. / supports NT Hash)
