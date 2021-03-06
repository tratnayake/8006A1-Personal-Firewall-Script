#!/bin/bash

IPT="/sbin/iptables"

#Flush any existing rules
$IPT -X
$IPT -F

#Default policies
$IPT -P INPUT DROP
$IPT -P FORWARD DROP
$IPT -P OUTPUT DROP

#Create the chains
$IPT -N HTTPIN
$IPT -N HTTPOUT

$IPT -N HTTPDENYIN
$IPT -N HTTPDENYOUT

$IPT -N SSHIN
$IPT -N SSHOUT

$IPT -N CUSTOMALLOWOUT
$IPT -N CUSTOMALLOWIN

$IPT -N CUSTOMDENYIN
$IPT -N CUSTOMDENYOUT

$IPT -N OTHEROUT
$IPT -N OTHERIN


#Allow rules for chains
$IPT -A HTTPIN -j ACCEPT
$IPT -A HTTPOUT -j ACCEPT
$IPT -A HTTPDENYIN -j DROP
$IPT -A HTTPDENYOUT -j DROP

$IPT -A SSHIN -j ACCEPT
$IPT -A SSHOUT -j ACCEPT

$IPT -A CUSTOMALLOWIN -j ACCEPT
$IPT -A CUSTOMALLOWOUT -j ACCEPT

$IPT -A OTHERIN -j ACCEPT
$IPT -A OTHEROUT -j ACCEPT

$IPT -A CUSTOMDENYIN -j DROP
$IPT -A CUSTOMDENYOUT -j DROP

$IPT -A HTTPDENYIN -j DROP


#Allow DNS
	#Allow going OUT to port 53 (initiating a DNS request)
	$IPT -A OUTPUT -p UDP --dport 53 -j OTHEROUT
	#Allow coming IN FROM port 53 (DNS reply)
	$IPT -A INPUT -p UDP --sport 53 -j OTHERIN
	#Factor for TCP in case UDP times out.
	$IPT -A OUTPUT -p TCP --dport 53 -j OTHEROUT
	$IPT -A INPUT -p TCP --sport 53 -j OTHERIN

#Allow DHCP
	$IPT -A OUTPUT -p UDP --dport 68 -j OTHEROUT
	$IPT -A INPUT -p UDP --sport 68 -j  OTHERIN
	$IPT -A OUTPUT -p TCP --dport 68 -j OTHEROUT
	$IPT -A INPUT -p TCP --sport 68 -j  OTHERIN

#Allow inbount/outbound SSH packets
	#Allow SSH connection request (coming in to local 22)
	$IPT -A INPUT -p TCP --dport 22 -j SSHIN
	#Send REPLY to SSH connection out
	$IPT -A OUTPUT -p TCP --sport 22 -j SSHOUT
	#Let SSH replies through
	$IPT -A INPUT -p TCP --sport 22 -j SSHIN
	#Let SSH connections go out
	$IPT -A OUTPUT -p TCP --dport 22 -j SSHOUT
	#UDP just in case
	$IPT -A INPUT -p UDP --dport 22 -j SSHIN
	$IPT -A OUTPUT -p UDP --dport 22 -j SSHOUT


#Drop all incoming packets from reserved port 0
	$IPT -A INPUT -p TCP --sport 0 -j CUSTOMDENYIN
	$IPT -A OUTPUT -p TCP --dport 0 -j CUSTOMDENYOUT
 

# Drop inbound traffic to port 80(http) from source ports less than 1024
#echo 'Drop http from source ports less than 1024'
	$IPT -A INPUT -p tcp --dport 80 ! --sport 1:1023 -j HTTPIN
	$IPT -A INPUT -p tcp --dport 80 --sport 1:1023 -j HTTPDENYIN


#Allow inbound/outbound WWW packets
	#Allow outbound HTTP requests ( to a website or something)
	$IPT -A OUTPUT -p TCP -m multiport --dport 80,443 -j HTTPOUT
	#Allow replies from those websites
	$IPT -A INPUT -p TCP -m multiport --sport 80,443 -j HTTPIN

	#Allow HTTP connection requests IN (to use your appache server)
	$IPT -A INPUT -p TCP -m multiport --dport 80,443 -j HTTPIN
	#Allow HTTP replies out
	$IPT -A OUTPUT -p TCP -m multiport --sport 80,443 -j HTTPOUT
	
	



echo "New IPTABLES SET";


service iptables save
service iptables restart

#iptables -L -v -x -n

