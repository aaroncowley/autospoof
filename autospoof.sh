#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi


if [ ! -d "/root/portspoof" ]; then
    # Control will enter here if portspoof doesn't exist.
    git clone https://github.com/drk1wi/portspoof.git /root
    /root/portspoof/configure 
    /root/portspoof/make
    /root/portspoof/make install
fi

iptables --table nat -F

#change this line - sets the ranges in a variable
spoofed="1:19 23:138 140:442 444:65535"

for prange in ${spoofed}; do
    iptables -t nat -A PREROUTING -i eth0 -p tcp -m tcp --dport ${prange} -j REDIRECT --to-ports 4444
done

/usr/local/bin/portspoof -c /root/portspoof/tools/portspoof.conf -s /root/portspoof/tools/portspoof_signatures -D

iptables --table nat --list

if grep -q /root/autospoof.sh /etc/rc.local; then
    echo already in rc.local
else
    echo "/bin/bash /root/autospoof.sh" >> /etc/rc.local
fi

echo "All DONE"
exit 1
