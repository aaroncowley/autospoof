#! /bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

cd /root

if [ ! -d "/root/portspoof" ]; then
    # Control will enter here if portspoof doesn't exist.
    git clone https://github.com/drk1wi/portspoof.git && cd portspoof
    ./configure 
    make
    make install
fi

#change this line - sets the ranges in a variable
spoofed="1:19 23:79 81:138 140:442 444:4199 4201:65535"

for prange in ${spoofed}; do
    iptables -t nat -A PREROUTING -i eth0 -p tcp -m tcp --dport ${prange} -j REDIRECT --to-ports 4444
done

portspoof -c /root/portspoof/portspoof/tools/portspoof.conf -s /root/portspoof/portspoof/tools/portspoof_signatures -D
iptables --table nat --list

string="$(grep -rnw /var/spool/cron/ -e /root/autospoof.sh)"
if [[ ! *"/root/autospoof.sh"* == ${string} ]]; then
    (crontab -l ; echo "@reboot /bin/bash /root/autospoof.sh") | crontab -
fi

echo "All DONE"
exit 1
