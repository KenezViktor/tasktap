#!/bin/bash

# Variable to control the loop
running=true

# Function to handle SIGUSR1 signal
handle_signal() {
    echo "SIGUSR1 received. Stopping the script..."
    running=false
}

# Trap SIGUSR1 signal and call the handle_signal function
trap handle_signal SIGUSR1

echo "Script is running. Send SIGUSR1 signal to stop it (e.g., kill -SIGUSR1 $$)."

i=0
start_time=$(date +"%Y-%m-%dT%H-%M-%S")

curl -m 5 -s "http://tasktap.local/server.php?op=init" > /dev/null

# Infinite loop
while $running; do
    curl -m 5 -s "http://tasktap.local/server.php?op=add&r=${start_time}&i=${i}" > /dev/null
    sleep 1
    ((i++));
done

curl -m 5 -s "http://tasktap.local/server.php?op=list&r=${start_time}" > ${start_time}_log.json
    
echo "Script stopped."
