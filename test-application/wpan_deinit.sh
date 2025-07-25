#!/bin/bash
set -x
i=0
phy_id=0

ip link set lowpan${i} down
#ip link set monitor${i} down
ip link set wpan${i} down
ip link delete lowpan${i}
ip link delete monitor${i}