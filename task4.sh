#!/bin/bash

Host=127.0.0.1
Port=12345

logfile="/home/bilal/bilal/port.log"

# step1 : Check  if any process using the port
Port_Status=$(netstat -tulnp | grep "$Host:$Port")

# step2 : If Port Is not Found, log it
if [ -z "$Port_Status" ]; then
echo "$(date): Port $Port on $Host is not Active " >> $logfile
else
echo "$(date): Port $Port on $Host is Active " >> $logfile
fi
