#!/bin/bash
#
# This script displays host identification information for a Linux machine.
#
# Sample output:
#   Hostname      : zubu
#   LAN Address   : 192.168.2.2
#   LAN Name      : net2-linux
#   External IP   : 1.2.3.4
#   External Name : some.name.from.our.isp

# Accept options on the command line for verbose mode and an interface name
verbose=""
interface_name=""

# Loop through the command line arguments

while getopts "v" opt; do
    case "$opt" in
        v)
            verbose=true
            ;;
        \?)
            usage
            ;;
    esac
done

# Dynamically identify the list of interface names for the computer running the script
interfaces=$(ip -br link show | awk '$1 != "lo" {print $1}')

# Loop through the list of interfaces
for interface in $interfaces; do
    if [ -n "$interface_name" ] && [ "$interface_name" != "$interface" ]; then
        continue
    fi

    [ "$verbose" = "yes" ] && echo "Getting information for interface $interface"

    # Find the IP address and hostname for the interface
    ipv4_address=$(ip -br a s dev $interface | awk '{print $3}' | cut -d/ -f1)
    ipv4_hostname=$(nslookup -type=PTR "$ipv4_address" | awk -F 'name = ' '/name =/{print $2}' | awk '{print $1}' | sed 's/\.$//')

    # Identify the network number for this interface and its name if it has one
    network_address=$(ip -4 -o addr show dev $interface_name | awk '{print $4}' | cut -d/ -f1 | awk -F. 'BEGIN {OFS="."} {print $1,$2,$3,"0"}')
    network_number=$(echo "$network_address" | awk -F. '{print ($1 * 2^24) + ($2 * 2^16) + ($3 * 2^8)}')
    network_name=$(getent networks | awk -v n=$network_number '$1 == n {print $2}')
    # Display the interface information
    cat <<EOF

Interface $interface:
===============
Address         : $ipv4_address
Name            : $ipv4_hostname
Network Address : $network_address
Network Name    : $network_name

EOF
done

