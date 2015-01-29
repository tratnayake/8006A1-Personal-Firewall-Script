#!/bin/bash

NOW=$(date +"%m-%d-%Y")
filename="Logfile$NOW.txt"



function startTestPrompt {
	echo "Press any key to START TEST $1 $2 (START YOUR WIRESHARK CAP)"
	read anykey
	echo "START Test $1 $2" >> $filename
	iptables -L -v -x -n >> $filename

	wireshark -k -i eno16777736 -a duration:10 -w ./Captures/Test"$1".pcapng &
	sleep 5

}

function endTestPrompt {
	echo "Press any key to END TEST $1 $2 (STOP AND SAVE YOUR WIRESHARK CAP)"
	read anykey
	echo "END Test $1" >> $filename
	iptables -L -v -x -n >> $filename
}

function installPackages {

	yum  -y install hping3

	yum -y install sshpass

	yum -y install httpd

	echo "Packages installed"
}

function testDHCP {

	startTestPrompt "$1" ": Allow Inbound/Outbound DHCP" 



	ifconfig

	echo "Releasing DHCP"
	dhclient -r

	sleep 3

	echo "DHCP released"
	ifconfig  

	echo
	echo "Getting new IP address"
	dhclient

	sleep 2

	ifconfig 

	endTestPrompt "$1: Allow Inbound/Outbound DHCP" 
}

function testDNS {

	sleep 2

	startTestPrompt "$1" ": Allow Inbound/Outbound DNS" 

	nslookup www.miniclip.com

	endTestPrompt "$1: Allow Inbound/Outbound DNS"
}

function testSSH {

	#Test normal operation of SSH
	startTestPrompt "$1A" ": Allow outbound SSH to a host" 

	sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$user"@"$remoteIP" ifconfig 

	endTestPrompt "$1A: Allow outbound SSH to a host" 

	#Test inbound SSH
	startTestPrompt "$1B: Allow inbound SSH to a host" 

	sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$user"@"$remoteIP" hping3 $localIP -S -s 6000 -p 22 -c 5 -k

	endTestPrompt "$1B: Allow inbound SSH to a host" 

}

function testCustomRules {

	#Test incoming drop packets from port 0
	startTestPrompt "$1A" ": Drop all incoming traffic from port 0" 

	sleep 2

	sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$user"@"$remoteIP" hping3 "$localIP" -S -s 0 -p 80 -c 5 -k

	endTestPrompt "$1A: Drop all incoming traffic from port 0"

	#Test DON'T drop incoming all packets TO 0
	#startTestPrompt "$1B" ": DON'T drop incoming all packets TO 0" 

	#sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$user"@"$remoteIP" hping3 "$localIP" -S -s 93 -p 0 -c 5 -k

	#endTestPrompt "$1B:DON'T drop incoming all packets TO 0"

	#Test Drop all outgoing packets to 0
	startTestPrompt "$1C" ":  Drop all outgoing packets to 0" 

	 hping3 "$remoteIP" -S -s 93 -p 0 -c 5  

	endTestPrompt "$1C: Drop all outgoing packets to 0"

	#Test DON'T drop all going from port 0
	#startTestPrompt "$1D" ":  DON'T Drop all outgoing packets FROM 0" 

	 #hping3 "$remoteIP" -S -s 0 -p 80 -c 5  

	#endTestPrompt "$1D: DON't Drop all outgoing packets from 0"
}

function testDeniedHTTP {

	#Drop inbound packets to port 80 on ports 1-1024
	startTestPrompt "$1A" ": Drop all incoming traffic TO port 80 from ports 1-1024" 

	sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$user"@"$remoteIP" hping3 "$localIP" -S -s 1019 -p 80 -c 5 

	endTestPrompt "$1A: Drop all incoming traffic TO port 80 from ports 1-1024"

	#DONT Drop inbound packets to port 80 on ports !1-1024
	startTestPrompt "$1B" ": DON'T drop all incoming traffic TO port 80 from ports !1-1024" 

	sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$user"@"$remoteIP" hping3 "$localIP" -S -s 1027 -p 80 -c 5  

	endTestPrompt "$1B: DON'T drop all incoming traffic TO port 80 from ports !1-1024"

}

function testHTTP {

	#Test Outbound HTTP
	startTestPrompt "$1A" ": Allow outbound HTTP" 

	hping3 www.google.com -S -s 2354 -p 80 -c 5

	endTestPrompt "$1A: Allow outbound HTTP"

	#Test Inbound HTTP
	startTestPrompt "$1B: Allow inbound HTTP"

	service httpd restart 

	sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$user"@"$remoteIP" hping3 "$localIP" -S -s 6000 -p 80 -c 5 -k

	endTestPrompt "$1B: Allow inbound HTTP"

}

#function testCustomHTTPrules {

	
#}




clear
echo "PLEASE MAKESURE YOU RUN THIS AS ROOT"



echo

#SETTING UP IPS

echo "What is the name of your Firewall script?"

read firewallscript

echo "What is the name of your RESET  Firewall script?"

read resetfirewallscript

sh $resetfirewallscript

echo "What is the IP of the machine you will be using to SSH into?"

read remoteIP

echo "What is the name of your NIC interface?"

read interface

echo "What is the IP of YOUR machine? 192.168.0.XX"

read localIP

echo "What is the user account to use for ssh'ing? (usually ROOT)"

read user

echo "What is the SSH password?"

read password

## IPS FINISHED

echo "The remote IP to connect to is $remoteIP"

echo "The IP of the remote machine you will be using to SSH into is $remoteIP"



installPackages

# START FIREWALL
sh $firewallscript


testDHCP 1

testDNS 2

testSSH 3

testCustomRules 4

testDeniedHTTP 5

testHTTP 6

echo "ALL TESTS COMPLETE!"

#sh ResetFirewall.sh









