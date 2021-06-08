#!/bin/bash

# sctipt to work system registration and vpn certificate fix for rhel 8.4 
# this is individual script use at own Knowledge


#kill current running process 
pkill -f vpn
pkill -f vpnui
pkill -f agent.py
pkill -f intranetid.py

#stop Besclinet service
sudo systemctl stop besclient

#download required packages to current folder
wget https://github.com/venkatnaveen-ibm/vpn-fix/raw/main/BESAgent-9.5.15.71-1.el8.1.x86_64.rpm
wget https://github.com/venkatnaveen-ibm/vpn-fix/raw/main/ibm-config-TEM-8.4.0-1.el8.noarch.rpm
wget https://github.com/venkatnaveen-ibm/vpn-fix/raw/main/li-el8-fix-reg.run

#installing packages replacing forcefully
sudo rpm -ivh --replacefiles --replacepkgs BESAgent-9.5.15.71-1.el8.1.x86_64.rpm ibm-config-TEM-8.4.0-1.el8.noarch.rpm

#run reg fix 
chmod 755 li-el8-fix-reg.run
sudo ./li-el8-fix-reg.run

#reset besclient user data
/opt/ibm/registration/bin/reset-besclient true

# running registration 
python3 /opt/ibm/registration/registration.py

#connecting anyconnect vpn to temporary gateway 
/opt/cisco/anyconnect/bin/vpn connect sasvpn06.emea.ibm.com/gettingstarted

#restart besclient
sudo systemctl stop besclient
sudo systemctl start besclient

#start and run agent.py in backgroud
python3 /opt/ibm/ibm-vpn-agent/agent.py

#check log file 
sudo cat /var/opt/BESClient/__BESData/__Global/Logs/$(date +%Y%m%d).log
