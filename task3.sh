#!/bin/bash

read -p "Enter Role Client/Server " Role
read -p "Enter Host ID: " host_IP
read -p "Enter Port NO: " Port

if [ $Role == "Server" ]; then
echo "Server Started on Port $Port :"
nc -l -p $Port 

elif [ $Role == "Client" ]; then
echo "Host Connecting to $Host_IP:$Port "
nc "$host_IP" "$Port"

else
echo"Invalid Role Bitte Enter Server or Client"
fi
