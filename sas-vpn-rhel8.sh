#!/bin/bash

# sctipt to work system registration and vpn certificate fix for rhel 8.4 
# this is individual script use at own Knowledge


ping -c 1 www.google.com > /dev/null

if [ $? -eq 0 ]; then
	echo "Internet Connected"
else
	echo "Check Internet connection"
	exit 0 ;
fi

pkill vpnui                # kill cisco anyconnet GUI application 
sudo pkill -f agent.py          # kill current running agent.py script
sudo pkill -f intranetid.py    # kill if W3 ID windows is open 

sudo systemctl stop besclient   #stop Besclinet service

#download required packages to current folder
wget https://github.com/venkatnaveenibm/vpn-fix/raw/main/BESAgent-9.5.15.71-1.el8.1.x86_64.rpm    # BESClient
wget https://github.com/venkatnaveenibm/vpn-fix/raw/main/ibm-config-TEM-8.4.0-1.el8.noarch.rpm     # ibm-config-TEM
wget https://github.com/venkatnaveenibm/vpn-fix/raw/main/ibm-vpn-agent-8.4-2.el8.1.noarch.rpm      # ibm-vpn-agent
wget https://github.com/venkatnaveenibm/vpn-fix/raw/main/li-el8-fix-reg.run                        # registration fix 

#installing packages replacing forcefully
sudo rpm -ivh --replacefiles --replacepkgs BESAgent-9.5.15.71-1.el8.1.x86_64.rpm ibm-config-TEM-8.4.0-1.el8.noarch.rpm ibm-vpn-agent-8.4-2.el8.1.noarch.rpm

#run reg fix 
chmod 755 li-el8-fix-reg.run
sudo ./li-el8-fix-reg.run

#reset besclient user data
/opt/ibm/registration/bin/reset-besclient true

# running registration 
python3 /opt/ibm/registration/registration.py

#connecting anyconnect vpn to temporary gateway 
echo -e"connect to sasvpn06.emea.ibm/gettingstarted in cisco"
/opt/cisco/anyconnect/bin/vpnui &

#restart besclient
sudo systemctl stop besclient
sleep 2
sudo systemctl start besclient

echo " Registration Successfull Please wait for 1 hr to syncronization and Certificate generation check logs as below \n"
sleep 5 
#check log file 
sudo cat /var/opt/BESClient/__BESData/__Global/Logs/$(date +%Y%m%d).log
