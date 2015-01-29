#!/bin/bash

IPT="/sbin/iptables"

$IPT -F
$IPT -X

$IPT -P INPUT ACCEPT
$IPT -P OUTPUT ACCEPT
$IPT -P FORWARD ACCEPT

echo "Firewalls are now reset :) "