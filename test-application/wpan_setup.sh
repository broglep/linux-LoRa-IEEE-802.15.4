#!/bin/bash

set -e
set -x

DEFAULT_MAC=$(cat /sys/class/net/wlan0/address)

declare -A short_address_assoc=(
    ['2c:cf:67:f0:bf:38']="0x1111"
    ['2c:cf:67:f0:bf:7c']="0x2222"
)

panid="0xbeef"
short_addr=${short_address_assoc[${DEFAULT_MAC}]}
i=0
phy_id=0

echo "Associating with $short_addr short address"

#iwpan phy phy${phy_id} set channel 0 11
#iwpan phy phy${phy_id} interface add monitor${i} type monitor

iwpan dev wpan${i} set pan_id $panid
iwpan dev wpan${i} set short_addr ${short_addr}


ip link add link wpan${i} name lowpan${i} type lowpan
ip link set wpan${i} up
ip link set lowpan${i} up
#ip link set monitor${i} up

# Firewall stuff to discard icmp6 neighbor discovery
# Delete all rules
ip6tables -F

# Block icmp6 neighbor messages
#Forbig multicast listener query
ip6tables -o lowpan0 -A OUTPUT -p icmpv6 --icmpv6-type 130 -j DROP
#Forbig multicast listener report
ip6tables -o lowpan0 -A OUTPUT -p icmpv6 --icmpv6-type 143 -j DROP
#Forbid neighbor solicitation
ip6tables -o lowpan0 -A OUTPUT -p icmpv6 --icmpv6-type 135 -j DROP
#Forbid router solicitation
ip6tables -o lowpan0 -A OUTPUT -p icmpv6 --icmpv6-type 133 -j DROP
#Forbid neighbor advertisement
ip6tables -o lowpan0 -A OUTPUT -p icmpv6 --icmpv6-type 136 -j DROP

# Block mdns
ip6tables -o lowpan0 -A OUTPUT -p udp --dport 5353 -j DROP

# Accept everything else
ip6tables -i lowpan0 -A INPUT -j ACCEPT
ip6tables -i lowpan0 -A FORWARD -j ACCEPT
ip6tables -o lowpan0 -A OUTPUT -j ACCEPT