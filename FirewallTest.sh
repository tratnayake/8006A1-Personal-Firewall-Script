#!/bin/bash
clear
echo "PLEASE MAKESURE YOU RUN THIS AS ROOT"



echo

#SETTING UP IPS

echo "What is the name of your Firewall script?"

read firewallscript

echo "What is the name of your RESET  Firewall script?"

read resetfirewallscript

sh $resetfirewallscript

echo "What is the IP of the machine you will be using to SSH into? 192.168.0.XX"

read remote

remoteIP="192.168.0.$remote"

echo "What is the IP of YOUR machine? 192.168.0.XX"

read loc

localIP="192.168.0.$loc"

## IPS FINISHED

echo "The remote IP to connect to is $remoteIP"

echo "The IP of the remote machine you will be using to SSH into is $remoteIP"

filename="Logfile.txt"


echo "Installing HPING3 if you don't have it"

yum  -y install hping3

yum -y install sshpass

yum -y install httpd

echo "Yum installed"

# START FIREWALL

sh $firewallscript


echo "Press any key to START TEST 1 Allow Outbound/Inbound DHCP (START YOUR WIRESHARK CAP)"
read anykey

echo "**Test 1: Allow inbound/outbound DHCP**\n" >> $filename

ifconfig em1

echo "Releasing DHCP"
dhclient -r

sleep 3

echo "DHCP released"
ifconfig em1 

echo
echo "Getting new IP address"
dhclient

sleep 3

ifconfig em1

echo "Press any key to FINISH TEST 1 (DHCP) (SAVE YOUR WIRESHARK STUFF)"
read anykey
#iptables -L -v >> $filename
echo


echo "Press any key to START TEST  2 inbound/outbound DNS (START YOUR WIRESHARK CAP)"
read anykey
echo "**Test 2: Allow inbound/outbound DNS**" >> $filename

nslookup www.google.com

#iptables -L -v >> $filename

echo "Press any key to FINISH TEST 2 (DNS) (SAVE YOUR WIRESHARK CAP)"
read anykey

echo

echo "Press any key to START TEST 3 Outbound/inbound SSH (START YOUR WIRESHARK CAP)"
read anykey
echo "**Test 3A: Allow outbound SSH **" >> $filename
sshpass -p "uest1onQ?" ssh -o StrictHostKeyChecking=no root@"$remoteIP" ifconfig em1

iptables -L -v >> $filename
echo  "FINISHED SSHING TEST 3A"

echo "**Test 3A: Allow inbound SSH **" >> $filename
echo "Press any key to START TEST 3B inbound SSH (START YOUR WIRESHARK CAP)"
read anykey

echo "**Test 3B: Allow incoming SSH **" >> $filename
sshpass -p "uest1onQ?" ssh -o StrictHostKeyChecking=no root@"$remoteIP" hping3 "$localIP" -S -s 22 -p 22 -c 15

iptables -L -v >> $filename

echo "Press any key to FNISH TEST SSH 3B (INBOUND SSH) (SAVE YOUR WIRESHARK CAP)"
read anykey


echo "Press any key to START TEST 4 Outbound HTTP (START YOUR WIRESHARK CAP)"
read anykey
echo "**Test 4A: Allow outbound HTTP **" >> $filename
hping3 www.tratnayake.me -p 80 -s 80 -c 15

iptables -L -v >> $filename
echo
echo "Press any key to FINISH TEST  --TAKE A SCREENSHOT OF THE SITE (www.tratnayake.me) -- (SAVE YOUR WIRESHARK CAP)"
read anykey


echo "Press any key to START TEST 4B (Inbound HTTP) (START YOUR WIRESHARK CAP)"
read anykey

service httpd start
echo "Starting your server";
echo "Inbound from a port 1021, SHOULD BE DROP" >>$filename
sshpass -p "uest1onQ?" ssh -o StrictHostKeyChecking=no root@"$remoteIP" hping3 "$localIP" -S -s 1021 -p 80 -c 5 -k
echo "Inbound from a port 1021, SHOULD BE ACCEPT" >>$filename
sshpass -p "uest1onQ?" ssh -o StrictHostKeyChecking=no root@"$remoteIP" hping3 "$localIP" -S -s 1025 -p 80 -c 5 -k

echo "Press any key to FINISH TEST 4 (Inbound HTTP) take a picture of your server from the other computer. (START YOUR WIRESHARK CAP)"
read anykey


function startTestPrompt {
	echo "Press any key to START TEST $1 (START YOUR WIRESHARK CAP)"
read anykey
}

function endTestPrompt {
	echo "Press any key to END TEST $1 (STOP AND SAVE YOUR WIRESHARK CAP)"
read anykey
}


#sh ResetFirewall.sh








