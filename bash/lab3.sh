#!/bin/bash

#use to exit the script if any commands fails to execute with non zero exit code
set -e

if which lxd &> /dev/null ; then
	echo "Lxd Already Installed"
	echo "Lxd Version: $(lxd version)"
else
	echo "Lxd Not Installed, Installing Lxd"
	#it may require sudo/admin password to install lxd
	sudo snap install lxd || { echo ' Something went wrong. Failed to install Lxd. '; exit 1; }
	echo "Lxd Installation Successful"
	echo "Installed Lxd Version: $(lxd version)"
fi 

# Checking if the lxdbr0 interface is already initialized in the system
if ip a show lxdbr0 &> /dev/null ; then
	echo "Interface lxdbr0 Already Initialized."
else
	# Initializing lxd, It may require sudo/admin passwords 
	sudo lxd init --auto || { echo "Something Went Wrong. Lxd Initialization Failed."; exit 1; }
	echo "Lxd Initialization Completed."
fi

if lxc list | grep -q COMP2101-S22.*RUNNING ; then
	echo "Container COMP2101-S22 is already running"
else
	echo "Launching Container COMP2101-S22"
	lxc launch ubuntu:20.04 COMP2101-S22 || { echo "Something Went Wrong. Container COMP2101-S22 failed to launch"; exit 1; }
	echo "Container COMP2101-S22 Launched successfully"
fi

if ! lxc exec COMP2101-S22 -- apache2 -v &> /dev/null 2>&1; then
	echo "Installing Apache2"
	lxc exec COMP2101-S22 -- sudo apt-get install -y apache2 >/dev/null 2>&1|| { echo "Something Went Wrong. Apache2 Installation Failed."; exit 1; }
	echo "Apache2 Installation Successful"
	echo "Apache2 Version: $(lxc exec COMP2101-S22 -- apache2 -v)"
else
	echo "Apache2 Already Installed"
	echo "Apache2 Version: $(lxc exec COMP2101-S22 -- apache2 -v)"
fi

# Get the IP address of the container
CONTAINER_IP=$(lxc list | grep -w COMP2101-S22 | awk '{print$6}')

# Add or update the entry in /etc/hosts for hostname COMP2101-S22 with the container’s current IP address if necessary
if ! grep -q "COMP2101-S22" /etc/hosts; then
    	echo "$CONTAINER_IP COMP2101-S22" | sudo tee -a /etc/hosts >/dev/null
else
    	sudo sed -i "s/^.*COMP2101-S22.*$/\"$CONTAINER_IP COMP2101-S22\"/" /etc/hosts
fi

# first checking if curl is installed or not
if ! lxc exec COMP2101-S22 -- curl --version &> /dev/null ; then
	echo "Installing Curl"
	#it may require sudo/admin password
	lxc exec COMP2101-S22 -- sudo apt-get install -y curl || { echo "Something Went Wrong. Curl Installation Failed."; exit 1; }
	echo "Curl Installed Successful"
	echo "Curl Version: $(lxc exec COMP2101-S22 -- curl --version)"
else
	echo "Curl Version: $(lxc exec COMP2101-S22 -- curl --version)"
fi

#Retrieving the default web page from the container COMP2101-S22's web service
if curl -s http://localhost &> /dev/null
then
	echo "Success in retrieving the webpage from container COMP2101-S22"
else
	echo "Failure in retrieving the webpage from container COMP2101-S22"
fi

