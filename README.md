#8006 Assignment 01 - Personal Linux Firewall (& Automated Testing Script)

Assignment 01 in COMP 8006 was an assignment which allowed us to apply concepts in building a firewall to meet certain requirements, as well as testing the firewall to ensure that the custom rules are working as intended.

The most valuable outcome of this assignment is the testing script, which has/does the following features:
* Modularizes the tests and allows future firewall architects to create new tests easily
* **Automatically opens and runs wireshark for 10 seconds at the beginning of each test. (Also saves with test number to /captures folder)**
* Writes iptables -L -v -x -n to a log file  at the beginning and end of a test to observe accounting rules

This assignment was done by [Thilina Ratnayake]

This assignment consists of 3 components:

  - Firewall.sh (Adds netfilter rules that sets up a firewall for the requirements of Assignment 01)
  - ResetFirewall.sh (Resets firewall settings after experiments to the status of computers in lab room 323 @ BCIT SE 12)
  - FirewallTest.sh (Runs tests for firewall rules as defined in Assignment 01)



### Version
0.0.1

### Firewall Requirements
1.  Allow DHCP
2.  Allow DNS
3.  Allow SSH traffic.
3.  Block outbound traffic to port 0
4.  Block inbound traffic from port 0
5.  Block inbound HTTP traffic from ports < 1024
6.  Allow all other HTTP and HTTPs traffic


### Tests
1. Allow DHCP
  * ifconfig (Check for ip address)
  *  DHCP release
  *  ifconfig (check for no IP)
  *  DHCP renew
  *  ifconfig (Check that ip address has been assigned)

2. Allow DNS
  * nslookup www.google.com (check for answer back)

3. Allow SSH traffic:
  * SSH into remote machine (This should work)
  * SSH into remote machine and send SSH packets via HPING3 to local machine. If replies come back, test successful.
  
 4. Block outbound traffic to port 0
   * HPING packets to port 0, no replies should come back

5. Block incoming traffic to port 0
  *SSH into remote machine, HPING packets to local machine. No replies should come back

6. Block inbound HTTP traffic from ports 0-1024
  *SSH into remote machine, send HPING packets to 80 from 1023, No replies should come back.

7. Allow all other HTTP and HTTPs traffic
  * Inbound: HPING to miniclip.com
  * Outbound:  
    * Start Apache
    * SSH into remote
    * HPING local machines apache server

### Adding tests
1.  Add a method at top of program with signature "testCondition"
2.  Execute test at bottom of program.

### Tech

The scripts will install the following packages automatically:
* HPING3 (to craft custom packets to send to certain ports)
* Wireshark (records and captures to packets to observe whether firewall rules are working)
* SSHPass (adds ability to login and execute commands through SSH on a BASH script)
* HTTPD (Apache) (To test wether HTTP packets are able to go outbound)

### Execution

To run and test the firewall, just run

```sh
$ sh TestFirewall.sh
```

### Need to know
*To edit firewall rules: EDIT Firewall.sh
*To edit firewall tests: EDIT TestFirewall.sh

### HPING Commands
Example
```sh
$ HPING3 192.168.0.14 -S -s 1023 -p 80 -c 15 -k
```
What this means:
Send 15 packets to 192.168.0.015 from port 1023 to port 80 and do not increment the starting port for those packets.

Parameters:
1. IP address of destination machine
2. -S = Set SYN flag on packet
3. -s = Source port 80
4. -p = Destination port 80
5. -c = Count, number of packets to send 15
6. -k = keep source port stuck on starting port.

### SSHPASS Commands
Example
```sh
$ sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$user"@"$remoteIP" hping3 "$localIP" ls -l;
```
What this does:
SSH into $remoteIP with username $user and password $password, then execute command "ls -l" on remote machine.





**PLAN 3 TIMES. START CODING. KEEP PLANNING**

[Thilina Ratnayake]:http://tratnayake.me/
