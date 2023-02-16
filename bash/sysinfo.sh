#!/bin/bash

hostname=$(hostname)
OSNAME=$(lsb_release -ds)
IP=$(ip route | grep default | cut -d ' ' -f3)
ROOTSPACE=$(df --output=avail -h / | tail -n1)

cat <<EOF

Report for my$hostname
==================
FQDN: $hostname
Operating System name and version: $OSNAME
IP Address: $IP
Root Filesystem Free Space: $ROOTSPACE
==================

EOF
