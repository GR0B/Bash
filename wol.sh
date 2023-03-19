#!/bin/bash

if [ $# -le 0 ]; then
# no Arg, print help
printf "WakeOnLAN scipt
Usage: wol.sh [mac]
example: wol.sh 00:11:22:33:44:55
"

else
    #Clean MAC of seperators
    dest=$(echo $1 | sed 's/[ :-]//g')
    
    # Magic packet = 6 ff followed by target MAC address 16 times, https://en.wikipedia.org/wiki/Wake-on-LAN#Magic_packet
    magicpacket=$(printf "f%.0s" {1..12}; printf "$dest%.0s" {1..16})
    
    # Hex-escape
    magicpacket=$(echo $magicpacket | sed -e 's/../\\x&/g')
    
    targetip="255.255.255.255"
    targetport="16"
    
    # Send magic packet with netcat
    printf "Sending magic packet..." 
    echo -e $magicpacket | nc -w1 -u $targetip $targetport
    printf " Done!"
fi
