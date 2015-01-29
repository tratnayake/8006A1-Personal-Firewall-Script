#!/bin/bash

date=date
filename="Logfile$date.txt"

function startTestPrompt {
	echo "Press any key to START TEST $1 (START YOUR WIRESHARK CAP)"
	read anykey
	echo "START Test $1" >> $filename
	iptables -L -v -x -n >> $filename

}

function endTestPrompt {
	echo "Press any key to END TEST $1 (STOP AND SAVE YOUR WIRESHARK CAP)"
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

	startTestPrompt "$1: Allow Inbound/Outbound DHCP" 



	ifconfig em1

	echo "Releasing DHCP"
	dhclient -r

	sleep 3

	echo "DHCP released"
	ifconfig em1 

	echo
	echo "Getting new IP address"
	dhclient

	sleep 2

	ifconfig em1

	endTestPrompt "$1: Allow Inbound/Outbound DHCP" 
}

function testDNS {

	startTestPrompt "$1: Allow Inbound/Outbound DNS" 

	nslookup www.miniclip.com

	endTestPrompt "$1: Allow Inbound/Outbound DNS"
}

function testSSH {

	#Test normal operation of SSH
	startTestPrompt "$1A: Allow outbound SSH to a host" 

	sshpass -p "uest1onQ?" ssh -o StrictHostKeyChecking=no root@"$remoteIP" ifconfig 

	endTestPrompt "$1A: Allow outbound SSH to a host" 

	#Test inbound SSH
	startTestPrompt "$1B: Allow inbound SSH to a host" 

	sshpass -p "uest1onQ?" ssh -o StrictHostKeyChecking=no root@"$remoteIP" hping3 192.168.0.14 -S -s 6000 -p 22 -c 5 

	endTestPrompt "$1B: Allow inbound SSH to a host" 

}

function testHTTP {

	#Test Outbound HTTP
	startTestPrompt "$1A: Allow outbound HTTP" 

	hping3 www.google.com -S -s 2354 -p 80 -c 5

	endTestPrompt "$1A: Allow outbound HTTP"

	#Test Inbound HTTP
	startTestPrompt "$1A: Allow inbound HTTP"

	service httpd restart 

	sshpass -p "uest1onQ?" ssh -o StrictHostKeyChecking=no root@"$remoteIP" hping3 "$localIP" -S -s 6000 -p 80 -c 5 

	endTestPrompt "$1A: Allow inbound HTTP"

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

## IPS FINISHED

echo "The remote IP to connect to is $remoteIP"

echo "The IP of the remote machine you will be using to SSH into is $remoteIP"



installPackages

# START FIREWALL
sh $firewallscript


testDHCP 1

#testDNS 2

#testSSH 3

#testHTTP 4

#sh ResetFirewall.sh









