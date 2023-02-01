#!/bin/bash
echo "FQDN: $(hostname)"  #(hostname) is replaced by the fully qualified domain name (FQDN) of the current system
echo "Host Information:"
hostnamectl status        #To check the information about the hostname configuration on a system
echo "IP Adresseses:"
hostname -I               #to display ip addresses pf the current system
echo "Root file status:" 
df /run                   # to check the disk space usage of the file system installed  on the /run directory.



